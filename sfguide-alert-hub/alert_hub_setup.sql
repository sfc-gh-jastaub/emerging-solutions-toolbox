/*************************************************************************************************************
Script:             Alert Hub
Create Date:        2023-04-05
Author:             B. Klein
Description:        Full alert demo and related orchestration
Copyright © 2023 Snowflake Inc. All rights reserved
**************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2023-04-05          B. Klein                            Initial Creation
2023-04-13          B. Klein                            Additional Configuration
2023-04-17          B. Klein                            Streamlit adjustment
2023-04-19          B. Klein                            Added timestamp columns
2024-03-20          B. Klein                            Repeatability building
*************************************************************************************************************/

/* setup roles */
use role accountadmin;
call system$wait(10);
create warehouse if not exists alerts_wh comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* create role and add permissions required by role for installation of solution */
create role if not exists alert_hub_role;

/* perform grants */
grant create database on account to role alert_hub_role;
grant execute task on account to role alert_hub_role;
grant create integration on account to role alert_hub_role;
grant execute alert on account to alert_hub_role;
grant role alert_hub_role to role sysadmin;
grant usage, operate on warehouse alerts_wh to role alert_hub_role;

/* setup provider side objects */
use role alert_hub_role;
use warehouse alerts_wh;
call system$wait(10);

create or replace database alert_hub comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';
create or replace schema alert_hub.example comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';
create or replace schema alert_hub.admin comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';
drop schema if exists alert_hub.public;
create or replace table alert_hub.example.records_to_test (name varchar, row_timestamp timestamp default current_timestamp()) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

use database alert_hub;
use schema alert_hub.admin;

/* Jinja parsing function */
create or replace function alert_hub.admin.get_sql_jinja(template string, parameters variant)
  returns string
  language python
  runtime_version = 3.10
  handler='apply_sql_template'
  packages = ('six','jinja2==3.0.3','markupsafe')
  comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
as
$$
# Most of the following code is copied from the jinjasql package, which is not included in Snowflake's python packages
from __future__ import unicode_literals
import jinja2
from six import string_types
from copy import deepcopy
import os
import re
from jinja2 import Environment
from jinja2 import Template
from jinja2.ext import Extension
from jinja2.lexer import Token
from markupsafe import Markup

try:
    from collections import OrderedDict
except ImportError:
    # For Python 2.6 and less
    from ordereddict import OrderedDict

from threading import local
from random import Random

_thread_local = local()

# This is mocked in unit tests for deterministic behaviour
random = Random()


class JinjaSqlException(Exception):
    pass

class MissingInClauseException(JinjaSqlException):
    pass

class InvalidBindParameterException(JinjaSqlException):
    pass

class SqlExtension(Extension):

    def extract_param_name(self, tokens):
        name = ""
        for token in tokens:
            if token.test("variable_begin"):
                continue
            elif token.test("name"):
                name += token.value
            elif token.test("dot"):
                name += token.value
            else:
                break
        if not name:
            name = "bind#0"
        return name

    def filter_stream(self, stream):
        """
        We convert
        {{ some.variable | filter1 | filter 2}}
            to
        {{ ( some.variable | filter1 | filter 2 ) | bind}}

        ... for all variable declarations in the template

        Note the extra ( and ). We want the | bind to apply to the entire value, not just the last value.
        The parentheses are mostly redundant, except in expressions like {{ '%' ~ myval ~ '%' }}

        This function is called by jinja2 immediately
        after the lexing stage, but before the parser is called.
        """
        while not stream.eos:
            token = next(stream)
            if token.test("variable_begin"):
                var_expr = []
                while not token.test("variable_end"):
                    var_expr.append(token)
                    token = next(stream)
                variable_end = token

                last_token = var_expr[-1]
                lineno = last_token.lineno
                # don't bind twice
                if (not last_token.test("name")
                    or not last_token.value in ('bind', 'inclause', 'sqlsafe')):
                    param_name = self.extract_param_name(var_expr)

                    var_expr.insert(1, Token(lineno, 'lparen', u'('))
                    var_expr.append(Token(lineno, 'rparen', u')'))
                    var_expr.append(Token(lineno, 'pipe', u'|'))
                    var_expr.append(Token(lineno, 'name', u'bind'))
                    var_expr.append(Token(lineno, 'lparen', u'('))
                    var_expr.append(Token(lineno, 'string', param_name))
                    var_expr.append(Token(lineno, 'rparen', u')'))

                var_expr.append(variable_end)
                for token in var_expr:
                    yield token
            else:
                yield token

def sql_safe(value):
    """Filter to mark the value of an expression as safe for inserting
    in a SQL statement"""
    return Markup(value)

def bind(value, name):
    """A filter that prints %s, and stores the value
    in an array, so that it can be bound using a prepared statement

    This filter is automatically applied to every {{variable}}
    during the lexing stage, so developers can't forget to bind
    """
    if isinstance(value, Markup):
        return value
    elif requires_in_clause(value):
        raise MissingInClauseException("""Got a list or tuple.
            Did you forget to apply '|inclause' to your query?""")
    else:
        return _bind_param(_thread_local.bind_params, name, value)

def bind_in_clause(value):
    values = list(value)
    results = []
    for v in values:
        results.append(_bind_param(_thread_local.bind_params, "inclause", v))

    clause = ",".join(results)
    clause = "(" + clause + ")"
    return clause

def _bind_param(already_bound, key, value):
    _thread_local.param_index += 1
    new_key = "%s_%s" % (key, _thread_local.param_index)
    already_bound[new_key] = value

    param_style = _thread_local.param_style
    if param_style == 'qmark':
        return "?"
    elif param_style == 'format':
        return "%s"
    elif param_style == 'numeric':
        return ":%s" % _thread_local.param_index
    elif param_style == 'named':
        return ":%s" % new_key
    elif param_style == 'pyformat':
        return "%%(%s)s" % new_key
    elif param_style == 'asyncpg':
        return "$%s" % _thread_local.param_index
    else:
        raise AssertionError("Invalid param_style - %s" % param_style)

def requires_in_clause(obj):
    return isinstance(obj, (list, tuple))

def is_dictionary(obj):
    return isinstance(obj, dict)

class JinjaSql(object):
    # See PEP-249 for definition
    # qmark "where name = ?"
    # numeric "where name = :1"
    # named "where name = :name"
    # format "where name = %s"
    # pyformat "where name = %(name)s"
    VALID_PARAM_STYLES = ('qmark', 'numeric', 'named', 'format', 'pyformat', 'asyncpg')
    def __init__(self, env=None, param_style='format'):
        self.env = env or Environment()
        self._prepare_environment()
        self.param_style = param_style

    def _prepare_environment(self):
        self.env.autoescape=True
        self.env.add_extension(SqlExtension)
        self.env.filters["bind"] = bind
        self.env.filters["sqlsafe"] = sql_safe
        self.env.filters["inclause"] = bind_in_clause

    def prepare_query(self, source, data):
        if isinstance(source, Template):
            template = source
        else:
            template = self.env.from_string(source)

        return self._prepare_query(template, data)

    def _prepare_query(self, template, data):
        try:
            _thread_local.bind_params = OrderedDict()
            _thread_local.param_style = self.param_style
            _thread_local.param_index = 0
            query = template.render(data)
            bind_params = _thread_local.bind_params
            if self.param_style in ('named', 'pyformat'):
                bind_params = dict(bind_params)
            elif self.param_style in ('qmark', 'numeric', 'format', 'asyncpg'):
                bind_params = list(bind_params.values())
            return query, bind_params
        finally:
            del _thread_local.bind_params
            del _thread_local.param_style
            del _thread_local.param_index

# Non-JinjaSql package code starts here
def quote_sql_string(value):
    '''
    If `value` is a string type, escapes single quotes in the string
    and returns the string enclosed in single quotes.
    '''
    if isinstance(value, string_types):
        new_value = str(value)
        new_value = new_value.replace("'", "''")
        #baseline sql injection deterrance
        new_value2 = re.sub(r"[^a-zA-Z0-9_.-]","",new_value)
        return "'{}'".format(new_value2)
    return value

def get_sql_from_template(query, bind_params):
    if not bind_params:
        return query
    params = deepcopy(bind_params)
    for key, val in params.items():
        params[key] = quote_sql_string(val)
    return query % params

def strip_blank_lines(text):
    '''
    Removes blank lines from the text, including those containing only spaces.
    https://stackoverflow.com/questions/1140958/whats-a-quick-one-liner-to-remove-empty-lines-from-a-python-string
    '''
    return os.linesep.join([s for s in text.splitlines() if s.strip()])

def apply_sql_template(template, parameters):
    '''
    Apply a JinjaSql template (string) substituting parameters (dict) and return
    the final SQL.
    '''
    j = JinjaSql(param_style='pyformat')
    query, bind_params = j.prepare_query(template, parameters)
    return strip_blank_lines(get_sql_from_template(query, bind_params))

$$;



-------------------------------- CONDITIONS --------------------------------
/* condition template table */
create or replace table alert_hub.admin.condition_template (template_name varchar, template_configuration varchar, last_updated_timestamp timestamp) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* condition table with reference to condition template */
create or replace table alert_hub.admin.condition (condition_name varchar, template_name varchar, parameters object, last_updated_timestamp timestamp) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* condition query function */
create or replace function alert_hub.admin.get_condition(condition_name varchar)
returns string
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
as
$$
select alert_hub.admin.get_sql_jinja(
        (
            select ct.template_configuration
            from alert_hub.admin.condition_template ct
            inner join alert_hub.admin.condition c    on ct.template_name = c.template_name
            where c.condition_name = CONDITION_NAME limit 1
        )
    ,   (
            select parameters
            from alert_hub.admin.condition c
            where c.condition_name = CONDITION_NAME limit 1
        )
)
$$
;

-------------------------------- NOTIFICATION INTEGRATIONS --------------------------------
/*
create integration table
parameters is for flexible sets fo values (pub/sub, email, etc.)
*/
create or replace table alert_hub.admin.notification_integration comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
(
        name varchar
    ,   enabled boolean
    ,   type varchar
    ,   parameters variant
    ,   last_updated_timestamp timestamp
);

/* construct notification integration */
create or replace function alert_hub.admin.construct_notification_integration(not_int_name varchar, type varchar, enabled boolean, parameters object)
returns string
language python
runtime_version = 3.10
packages=('snowflake-snowpark-python')
handler = 'construct_notification_integration'
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
as
$$
def construct_notification_integration(not_int_name, type, enabled, parameters):
    if type == 'EMAIL' or type == 'QUEUE':
        # Empty string
        parameters_string = str()

        # Construct string from parameters
        for key in parameters:
            parameters_string += key + "="

            if len(parameters[key]) > 1 and not isinstance(parameters[key], str):
                parameters_string += "("
                for index, item in enumerate(parameters[key]):
                    if index == 0:
                        parameters_string += parameters[key][index]
                    else:
                        parameters_string += "," + parameters[key][index]
                parameters_string += ")"
            elif isinstance(parameters[key], str):
                parameters_string += "'" + parameters[key] + "'"
            else:
                parameters_string += "("
                parameters_string += "'" + parameters[key][0] + "'"
                parameters_string += ")"

            parameters_string += "\n"

        # Generate sql statement
        sql_statement = """
            create or replace notification integration {not_int_name}
                type={type}
                enabled={enabled}
                {parameters_string}
        ;
        """.format(not_int_name=not_int_name, type=type, enabled=enabled, parameters_string=parameters_string)

        return sql_statement
    else:
        return 'Custom notification integrations not yet implemented'
$$
;

/* notification integration deployment procedure */
create or replace procedure alert_hub.admin.deploy_notification_integration(notification_integration_name varchar)
returns string
language python
runtime_version = 3.10
packages=('snowflake-snowpark-python')
handler = 'deploy_notification_integration'
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
execute as caller
as
$$
def deploy_notification_integration(session, notification_integration_name):
    notification_integration_sql = """
        select
            alert_hub.admin.construct_notification_integration(name, type, enabled, parameters)
        from alert_hub.admin.notification_integration
        where name = '{notification_integration_name}';
    """.format(notification_integration_name=notification_integration_name)

    creation_sql = session.sql(notification_integration_sql).collect()[0][0]

    deploy_sql = session.sql(creation_sql).collect()[0][0]

    return deploy_sql
$$
;

-------------------------------- ACTIONS --------------------------------
/* action template table */
create or replace table alert_hub.admin.action_template (template_name varchar, template_configuration varchar, last_updated_timestamp timestamp) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* action table with reference to template */
create or replace table alert_hub.admin.action (action_name varchar, template_name varchar, parameters object, last_updated_timestamp timestamp) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* action query function */
create or replace function alert_hub.admin.get_action(action_name varchar)
returns string
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
as
$$
select alert_hub.admin.get_sql_jinja(
        (
            select at.template_configuration
            from alert_hub.admin.action_template at
            inner join alert_hub.admin.action a    on at.template_name = a.template_name
            where a.action_name = ACTION_NAME limit 1
        )
    ,   (
            select parameters
            from alert_hub.admin.action
            where action_name = ACTION_NAME limit 1
        )
)
$$
;

-------------------------------- NOTIFICATION --------------------------------
/* message procedure */
create or replace procedure alert_hub.admin.notify(action_name varchar, condition_results array)
returns string
language python
runtime_version = 3.10
packages=('snowflake-snowpark-python')
handler = 'notify'
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
execute as caller
as
$$
import pandas as pd
import json

def notify(snowpark_session, action_name, condition_results):
    # Get condition results as JSON
    condition_results_df = pd.DataFrame.from_dict(condition_results)

    # Generate CSV for email
    condition_results_df = condition_results_df.to_csv(index=False)

    # Get db and schema
    current_db = snowpark_session.get_current_database()
    current_schema = snowpark_session.get_current_schema()

    # Get action parameters and replace {condition_results} with actual results
    action_parameters = snowpark_session.table([current_db, current_schema, "action"]).select("PARAMETERS").limit(1).collect()[0][0]
    action_parameters_json = json.loads(action_parameters)
    for key, value in action_parameters_json.items():
        if value == "{condition_results}":
            action_parameters_json[key] = condition_results_df

    # Get action statement
    action_statement_sql = """
        select alert_hub.admin.get_sql_jinja(
            (
                select template_configuration
                from alert_hub.admin.action_template at
                inner join alert_hub.admin.action a    on at.template_name = a.template_name
                where a.action_name = '{action_name}'
                limit 1
            )
        ,   (select {action_parameters})
        );
    """.format(action_name=action_name, action_parameters=action_parameters_json)

    # Get the action SQL and then run it
    action_df = snowpark_session.sql(action_statement_sql).collect()
    action_sql = action_df[0][0]
    result_df = snowpark_session.sql(action_sql).collect()

    # Return whether or not the action was completed
    return result_df[0][0]
$$;

-------------------------------- ALERTS --------------------------------
/* construct alert */
create or replace function alert_hub.admin.construct_alert(warehouse varchar, schedule varchar, alert_name varchar, condition_query varchar, action_name varchar)
returns string
language python
runtime_version = 3.10
handler = 'construct_alert'
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
as
$$
def construct_alert(warehouse, schedule, alert_name, condition_query, action_name):
    sql_statement = """
        create or replace alert {alert_name}
            warehouse={warehouse}
            schedule='{schedule}'
            if (exists(
                {condition_query}
            ))
            then call alert_hub.admin.notify(
                '{action_name}',
                (
                    select
                        array_agg(condition_result)
                    from (
                        select
                            object_construct(*) as condition_result
                        from  (
                            SELECT * FROM TABLE(RESULT_SCAN(SNOWFLAKE.ALERT.GET_CONDITION_QUERY_UUID()))
                        )
                    )
                ));
    """.format(warehouse=warehouse, schedule=schedule, alert_name=alert_name, condition_query=condition_query, action_name=action_name)

    return sql_statement
$$;

/* create alert configurations */
create or replace table alert_hub.admin.alert (warehouse_name varchar, alert_schedule varchar, alert_name varchar, condition_name varchar, action_name varchar, last_updated_timestamp timestamp) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

/* alert deployment procedure */
create or replace procedure alert_hub.admin.deploy_alert(alert_name varchar)
returns string
language python
runtime_version = 3.10
packages=('snowflake-snowpark-python')
handler = 'deploy_alert'
comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
execute as caller
as
$$
def deploy_alert(session, alert_name):
    condition_name_sql = """
        select
            ac.condition_name
        from alert_hub.admin.alert ac
        where ac.alert_name = '{alert_name}';
    """.format(alert_name=alert_name)

    condition_name = session.sql(condition_name_sql).collect()[0][0]

    get_condition_sql = """
        select alert_hub.admin.get_condition('{condition_name}');
    """.format(condition_name=condition_name)

    condition_sql = session.sql(get_condition_sql).collect()[0][0]

    condition_sql_escaped = condition_sql.replace("'","\\'")

    alert_sql = """
        select alert_hub.admin.construct_alert(
                warehouse_name
            ,   alert_schedule
            ,   alert_name
            ,   '{condition_sql_escaped}'
            ,   action_name
        )
        from alert_hub.admin.alert ac
        where ac.alert_name = '{alert_name}';
    """.format(alert_name=alert_name, condition_sql_escaped=condition_sql_escaped)

    creation_sql = session.sql(alert_sql).collect()[0][0]

    deploy_sql = session.sql(creation_sql).collect()[0][0]

    return deploy_sql
$$;

/* default templates */
insert into alert_hub.admin.condition_template
select
        'new_records'
    ,
$$select
    *
from identifier('{{ database | sqlsafe }}.{{ schema | sqlsafe }}.{{ table | sqlsafe }}')
where ({{ timestamp_column | sqlsafe }} between snowflake.alert.last_successful_scheduled_time() and snowflake.alert.scheduled_time())$$
    ,    current_timestamp()
;

insert into alert_hub.admin.action_template
select
        'email_users'
    ,
$$
CALL SYSTEM$SEND_EMAIL(
    {{ email_integration }},
    {% if emails %}'{{ emails[0] | sqlsafe }}'{% for email in emails[1:] %}, '{{ email  | sqlsafe }}'{% endfor %},{% endif %}
    '{{ email_subject | sqlsafe}}',
    '{{ email_body | sqlsafe}}'
)
$$
    ,    current_timestamp()
;

/* streamlit deployment */
create or replace schema alert_hub.deployment comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';
create or replace stage alert_hub.deployment.streamlit_stage comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';
create or replace table alert_hub.deployment.script (
	name varchar,
	script varchar(16777216)
) comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}';

create or replace procedure alert_hub.deployment.put_to_stage(stage varchar,filename varchar, content varchar)
returns string
language python
runtime_version=3.10
packages=('snowflake-snowpark-python')
handler='put_to_stage'
AS $$
import io
import os

def put_to_stage(session, stage, filename, content):
    local_path = '/tmp'
    local_file = os.path.join(local_path, filename)
    f = open(local_file, "w", encoding='utf-8')
    f.write(content)
    f.close()
    session.file.put(local_file, '@'+stage, auto_compress=False, overwrite=True)
    return "saved file "+filename+" in stage "+stage
$$;

insert into alert_hub.deployment.script values
(
        'streamlit'
    ,   $$from snowflake.snowpark.context import get_active_session
import streamlit as st
from abc import ABC, abstractmethod
import io
import os
import re
from snowflake.snowpark.functions import col, when_matched, when_not_matched, current_timestamp, call_function, \
    parse_json, upper


# Check snowflake connection type
def set_session():
    try:
        import snowflake.permissions as permissions

        session = get_active_session()

        # will fail for a non-native app
        privilege_check = permissions.get_held_account_privileges(["EXECUTE TASK"])

        st.session_state["streamlit_mode"] = "NativeApp"
    except:
        try:
            session = get_active_session()

            st.session_state["streamlit_mode"] = "SiS"
        except:
            import snowflake_conn as sfc

            session = sfc.init_snowpark_session("account_1")

            st.session_state["streamlit_mode"] = "OSS"

    return session


# Wide mode
st.set_page_config(layout="wide")

# Initiate session
session = set_session()

# Set starting page
if "page" not in st.session_state:
    st.session_state.page = "Welcome"


# Sets the page based on page name
def set_page(page: str):
    st.session_state.page = page


class Page(ABC):
    @abstractmethod
    def __init__(self):
        pass

    @abstractmethod
    def print_page(self):
        pass

    @abstractmethod
    def print_sidebar(self):
        pass


# Used for making text sql-compatible
def sanitize(text):
    cleaned_text = text \
        .replace("\'", "\\'") \
        .replace(";", "")

    return cleaned_text


def set_default_sidebar():
    # Sidebar for navigating pages
    with st.sidebar:
        st.title("Alert Hub 🚨")
        st.markdown("")
        st.markdown("This application helps define and manage conditions, notifications, actions, and alerts.")
        st.markdown("")
        if st.button(label="Conditions", help="Warning: Unsaved changes will be lost!"):
            set_page('Conditions')
            st.experimental_rerun()
        if st.button(label="Notification Integrations", help="Warning: Unsaved changes will be lost!"):
            set_page('Notification Integrations')
            st.experimental_rerun()
        if st.button(label="Actions", help="Warning: Unsaved changes will be lost!"):
            set_page('Actions')
            st.experimental_rerun()
        if st.button(label="Alerts", help="Warning: Unsaved changes will be lost!"):
            set_page('Alerts')
            st.experimental_rerun()
        st.markdown("")
        st.markdown("")
        st.markdown("")
        st.markdown("")
        if st.button(label="Return Home", help="Warning: Unsaved changes will be lost!"):
            set_page('Welcome')
            st.experimental_rerun()


class WelcomePage(Page):
    def __init__(self):
        self.name = "Welcome"

    def print_page(self):
        # Content for welcome page
        st.title("Welcome!")

        st.subheader("To get configure an alert, please walk through the pages in order.")
        st.write("The pages can also be navigated via the sidebar.")
        st.write("")
        pages_dict = {"Conditions": "Set what the alert should detect",
                      "Notification Integrations": "Enable notification integrations for use by actions - only "
                                                   "necessary for external actions (email, pub/sub, etc.)",
                      "Actions": "Set what the alert should do when triggered",
                      "Alerts": "Configure and deploy the alert itself, based on conditions/actions"}

        page_number = 0

        for key, value in pages_dict.items():
            page_number += 1
            tile = st.container()
            current_row = tile.columns(2)
            current_row[0].subheader(str(page_number) + " - " + key)
            current_row[0].caption(value)
            current_row[1].write("")
            if current_row[1].button("Go 🚀", key=key):
                set_page(key)
                st.experimental_rerun()

    def print_sidebar(self):
        set_default_sidebar()


class ConditionsPage(Page):
    def __init__(self):
        self.name = "Conditions"

    def print_page(self):
        # Content for conditions page
        # Method that a button uses to upsert a condition template
        def save_condition_template():
            source_df = session.create_dataframe(
                [[st.session_state['selected_condition_template'],
                  st.session_state['condition_template_configuration']]],
                schema=["TEMPLATE_NAME", "TEMPLATE_CONFIGURATION"]) \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('CONDITION_TEMPLATE')

            target_df.merge(
                source_df,
                (target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"]),
                [
                    when_matched().update(
                        {"TEMPLATE_CONFIGURATION": source_df["TEMPLATE_CONFIGURATION"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"TEMPLATE_NAME": source_df["TEMPLATE_NAME"],
                         "TEMPLATE_CONFIGURATION": source_df["TEMPLATE_CONFIGURATION"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            st.session_state['unique_condition_template_df'] = session.table('CONDITION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

            del st.session_state['selected_condition_template']

        # Method that a button uses to delete a condition template
        def delete_condition_template():
            source_df = session.create_dataframe([st.session_state['selected_condition_template']],
                                                 schema=["TEMPLATE_NAME"])
            target_df = session.table('CONDITION_TEMPLATE')

            target_df.delete(target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"], source_df)

            st.session_state['unique_condition_template_df'] = session.table('CONDITION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

            del st.session_state['selected_condition_template']

        # Remove unique_condition_df sessions state
        def reset_unique_condition_state(initial):
            if 'unique_condition_df' in st.session_state:
                if initial != st.session_state['selected_condition_template']:
                    del st.session_state['unique_condition_df']

        # Method that a button uses to preview a condition query
        def preview_condition():
            try:
                template_config = st.session_state['condition_template_configuration']
                parameter_config = sanitize(st.session_state['condition_parameter_configuration'])

                preview_df = session.create_dataframe([[template_config, parameter_config]],
                                                      schema=["TEMPLATE_CONFIGURATION", "PARAMETERS_STRING"]) \
                    .with_column("PARAMETERS", parse_json(col("PARAMETERS_STRING"))) \
                    .select(call_function("GET_SQL_JINJA", [col("TEMPLATE_CONFIGURATION"), col("PARAMETERS")]))

                st.session_state['generated_condition_preview'] = preview_df.collect()[0][0]
            except Exception as ex:
                st.session_state['generated_condition_preview'] = "Parsing failed -\n" \
                                                                  "Type: " + str(type(ex)) + "\n" \
                                                                                             "Message: " + str(ex)

        # Method that a button uses to save a condition
        def save_condition():
            source_df = session.create_dataframe(
                [[st.session_state['selected_condition'], st.session_state['selected_condition_template'],
                  sanitize(st.session_state['condition_parameter_configuration'])]],
                schema=["CONDITION_NAME", "TEMPLATE_NAME", "PARAMETERS_STRING"]) \
                .with_column("PARAMETERS", parse_json(col("PARAMETERS_STRING"))) \
                .drop("PARAMETERS_STRING") \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('CONDITION')

            target_df.merge(
                source_df,
                ((target_df["CONDITION_NAME"] == source_df["CONDITION_NAME"]) &
                 (target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"])),
                [
                    when_matched().update(
                        {"PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"CONDITION_NAME": source_df["CONDITION_NAME"],
                         "TEMPLATE_NAME": source_df["TEMPLATE_NAME"],
                         "PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            st.session_state['unique_condition_df'] = session.table('CONDITION') \
                .filter(col('TEMPLATE_NAME') == selected_condition_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('CONDITION_NAME')).distinct()

            del st.session_state['selected_condition']

        # Method that button uses to delete a condition
        def delete_condition():
            source_df = session.create_dataframe([st.session_state['selected_condition']], schema=["CONDITION_NAME"])
            target_df = session.table('CONDITION')

            target_df.delete(target_df["CONDITION_NAME"] == source_df["CONDITION_NAME"], source_df)

            st.session_state['unique_condition_df'] = session.table('CONDITION') \
                .filter(col('TEMPLATE_NAME') == selected_condition_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('CONDITION_NAME')).distinct()

            del st.session_state['selected_condition']

        st.title("Conditions")
        st.write("Set what the alert should detect by defining a template name and configuration")

        # Configured conditions
        conditions_df = session.table("CONDITION").sort(col('LAST_UPDATED_TIMESTAMP').desc()).distinct().to_pandas()
        conditions_df = conditions_df.replace(r'\n', ' ', regex=True)

        with st.expander("Configured Conditions"):
            st.dataframe(conditions_df, use_container_width=True)

        # ------------------------ CONDITION TEMPLATES ------------------------
        st.subheader("1 - Condition Templates")
        st.caption("A _Condition Template_ is used to define a general format of a query condition")

        # Available condition templates
        if 'unique_condition_template_df' not in st.session_state:
            st.session_state['unique_condition_template_df'] = session.table('CONDITION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

        unique_condition_template_df = st.session_state['unique_condition_template_df']

        # Template list and addition
        condition_template_col1, condition_template_col2 = st.columns((2, 1))

        if 'selected_condition_template' not in st.session_state:
            if unique_condition_template_df.count() > 0:
                st.session_state['selected_condition_template'] = unique_condition_template_df.collect()[0][0]
            else:
                st.session_state['selected_condition_template'] = ''

        initial_condition_template = st.session_state['selected_condition_template']
        selection_index = 0

        with condition_template_col2:
            # New condition template
            with st.form("condition_template_form"):
                st.write("New Condition Template Entry")

                new_condition_template_name = st.text_input('New Condition Template Name', label_visibility='collapsed',
                                                            placeholder='New template name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new template can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_condition_template_name]], schema=['TEMPLATE_NAME'])
                    unique_condition_template_df = session.table('CONDITION_TEMPLATE') \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col('TEMPLATE_NAME')).distinct()
                    unique_condition_template_df = new_df.union_all(unique_condition_template_df).distinct()
                    st.session_state['unique_condition_template_df'] = unique_condition_template_df

        with condition_template_col1:
            selected_condition_template = st.radio('Configured Condition Templates',
                                                   unique_condition_template_df.collect(),
                                                   key='selected_condition_template',
                                                   index=selection_index,
                                                   on_change=reset_unique_condition_state,
                                                   args=[initial_condition_template])

        # Condition template config
        condition_template_config_df = session.table('CONDITION_TEMPLATE').select(col('TEMPLATE_CONFIGURATION')).filter(
            col('TEMPLATE_NAME') == st.session_state.selected_condition_template).distinct()

        if condition_template_config_df.count() > 0:
            condition_template_config = \
                session.table('CONDITION_TEMPLATE').select(col('TEMPLATE_CONFIGURATION')).filter(
                    col('TEMPLATE_NAME') == st.session_state.selected_condition_template).distinct().collect()[0][0]
        else:
            condition_template_config = ''

        # Template config and saving
        condition_template_config_col1, condition_template_config_col2 = st.columns((6, 1))

        with condition_template_config_col1:
            condition_template_configuration = st.text_area('Selected Condition Template Query',
                                                            condition_template_config,
                                                            height=200,
                                                            key='condition_template_configuration',
                                                            placeholder='Enter valid SQL or JINJA')

        with condition_template_config_col2:
            st.header("")
            st.button("Save Template", on_click=save_condition_template)
            st.button("Delete Template", on_click=delete_condition_template)

        # ------------------------ CONDITIONS ------------------------
        st.subheader("2 - Conditions by Template")
        st.caption("A _Condition_ is a set a parameters that, in conjunction a condition template, generates a full "
                   "condition query")

        # Available conditions
        if 'unique_condition_df' not in st.session_state:
            st.session_state['unique_condition_df'] = session.table('CONDITION') \
                .filter(col('TEMPLATE_NAME') == selected_condition_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('CONDITION_NAME')).distinct()

        unique_condition_df = st.session_state['unique_condition_df']

        # List of conditions
        condition_col1, condition_col2 = st.columns((2, 1))

        selection_index = 0

        # Form
        with condition_col2:
            # New condition
            with st.form("condition_form"):
                st.write("New Condition Entry")

                new_condition_name = st.text_input('New Condition Name', label_visibility='collapsed',
                                                   placeholder='New condition name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new condition can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_condition_name]], schema=['CONDITION_NAME'])
                    unique_condition_df = st.session_state['unique_condition_df'] = session.table('CONDITION') \
                        .filter(col('TEMPLATE_NAME') == selected_condition_template) \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col('CONDITION_NAME')).distinct()
                    unique_condition_df = new_df.union_all(unique_condition_df).distinct()
                    st.session_state['unique_condition_df'] = unique_condition_df

        # Radio list of conditions
        with condition_col1:
            selected_condition = st.radio('Configured Conditions', unique_condition_df.collect(),
                                          key='selected_condition',
                                          index=selection_index)

        condition_parameter_col1, condition_parameter_col2 = st.columns((6, 1))

        with condition_parameter_col1:
            # Condition parameters
            condition_parameter_config_df = session.table('CONDITION').select(col('PARAMETERS')) \
                .filter(col('CONDITION_NAME') == st.session_state.selected_condition).distinct()

            if condition_parameter_config_df.count() > 0:
                condition_parameter_config_df = session.table('CONDITION').select(col('PARAMETERS')) \
                    .filter(col('CONDITION_NAME') == st.session_state.selected_condition).distinct().collect()[0][0]
            else:
                condition_parameter_config_df = ''

            condition_parameter_configuration = st.text_area('Selected Condition Parameters',
                                                             condition_parameter_config_df,
                                                             height=200,
                                                             key='condition_parameter_configuration',
                                                             placeholder='Enter valid JSON')

        with condition_parameter_col2:
            st.header("")
            st.button("Preview Condition", on_click=preview_condition)
            st.button("Save Condition", on_click=save_condition)
            st.button("Delete Condition", on_click=delete_condition)

        generated_condition_preview_text = ""

        if 'generated_condition_preview' in st.session_state:
            generated_condition_preview_text = st.session_state['generated_condition_preview']

        generated_condition_preview = st.text_area('Generated Preview', generated_condition_preview_text,
                                                   height=200,
                                                   placeholder='Click Preview Condition button')

    def print_sidebar(self):
        set_default_sidebar()


class NotificationIntegrationsPage(Page):
    def __init__(self):
        self.name = "Notification Integrations"

    def print_page(self):
        # Content for notification integrations page
        # Method that a button uses to upsert a notification integration
        def save_notification_integration():
            source_df = session.create_dataframe(
                [[st.session_state['selected_notification_integration'],
                  st.session_state['is_notification_integration_enabled'],
                  st.session_state['notification_integration_type'],
                  sanitize(st.session_state['notification_integration_parameters'])]],
                schema=["NAME", "ENABLED", "TYPE", "PARAMETERS_STRING"]) \
                .with_column("PARAMETERS", parse_json(col("PARAMETERS_STRING"))) \
                .drop("PARAMETERS_STRING") \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('NOTIFICATION_INTEGRATION')

            target_df.merge(
                source_df,
                (target_df["NAME"] == source_df["NAME"]),
                [
                    when_matched().update(
                        {"ENABLED": source_df["ENABLED"],
                         "TYPE": source_df["TYPE"],
                         "PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"NAME": source_df["NAME"],
                         "ENABLED": source_df["ENABLED"],
                         "TYPE": source_df["TYPE"],
                         "PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            session.call("deploy_notification_integration", st.session_state['selected_notification_integration'])

            st.session_state['unique_notification_integration_df'] = session.table('NOTIFICATION_INTEGRATION') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('NAME')).distinct()

            del st.session_state['selected_notification_integration']

        # Method that a button uses to delete a notification integration
        def delete_notification_integration():
            integration_name = st.session_state['selected_notification_integration']

            sql_text = "drop notification integration if exists {integration_name};".format(
                integration_name=integration_name)

            # Drop integration
            session.sql(sql_text).collect()

            # Drop NOTIFICATION_INTEGRATION record
            source_df = session.create_dataframe([integration_name], schema=["NAME"])
            target_df = session.table('NOTIFICATION_INTEGRATION')

            target_df.delete(target_df["NAME"] == source_df["NAME"], source_df)

            st.session_state['unique_notification_integration_df'] = session.table('NOTIFICATION_INTEGRATION') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('NAME')).distinct()

            del st.session_state['selected_notification_integration']

        # Remove unique_action_df sessions state
        def reset_unique_notification_integration_state(initial):
            if 'unique_notification_integration_df' in st.session_state:
                if initial != st.session_state['selected_notification_integration']:
                    del st.session_state['unique_notification_integration_df']

        st.title("Notification Integrations")
        st.write("Configure notification integrations for actions to use - only necessary for external actions")
        st.write("[Official Documentation](https://docs.snowflake.com/en/sql-reference/sql/create-notification"
                 "-integration)")

        # Configured notification integrations
        notification_integrations_df = session.table("NOTIFICATION_INTEGRATION") \
            .sort(col('LAST_UPDATED_TIMESTAMP').desc()).distinct().to_pandas()
        notification_integrations_df = notification_integrations_df.replace(r'\n', ' ', regex=True)

        # Replace with editable dataframe when available in SiS
        with st.expander("Configured Notification Integrations", expanded=True):
            st.dataframe(notification_integrations_df, use_container_width=True)

        # Available action templates
        if 'unique_notification_integration_df' not in st.session_state:
            st.session_state['unique_notification_integration_df'] = session.table('NOTIFICATION_INTEGRATION') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('NAME')).distinct()

        unique_notification_integration_df = st.session_state['unique_notification_integration_df']

        notification_integration_types = ['EMAIL', 'QUEUE']

        # Integration list and addition
        notification_integration_col1, notification_integration_col2 = st.columns((2, 1))

        if 'selected_notification_integration' not in st.session_state:
            if unique_notification_integration_df.count() > 0:
                st.session_state['selected_notification_integration'] = unique_notification_integration_df.collect()[0][0]
            else:
                st.session_state['selected_notification_integration'] = ''

        initial_notification_integration = st.session_state['selected_notification_integration']
        selection_index = 0

        with notification_integration_col2:
            # New action template
            with st.form("notification_integration_form"):
                st.write("New Notification Integration Entry")

                new_notification_integration_name = st.text_input('New Notification Integration Name',
                                                                  label_visibility='collapsed',
                                                                  placeholder='New integration name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new integration can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_notification_integration_name.replace(" ","_")]], schema=['NAME'])
                    unique_notification_integration_df = session.table("NOTIFICATION_INTEGRATION") \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col("NAME")).distinct()
                    unique_notification_integration_df = new_df.union_all(unique_notification_integration_df).distinct()
                    st.session_state['unique_notification_integration_df'] = unique_notification_integration_df

        with notification_integration_col1:
            selected_notification_integration = st.radio('Configured Notification Integrations',
                                                         unique_notification_integration_df.collect(),
                                                         key='selected_notification_integration',
                                                         index=selection_index,
                                                         on_change=reset_unique_notification_integration_state,
                                                         args=[initial_notification_integration])

        # Integration template config
        notification_integration_config_df = session.table('NOTIFICATION_INTEGRATION').select(col('PARAMETERS')).filter(
            col('NAME') == st.session_state.selected_notification_integration).distinct()

        if notification_integration_config_df.count() > 0:
            notification_integration_config = \
                session.table('NOTIFICATION_INTEGRATION').select(col('PARAMETERS')).filter(
                    col('NAME') == st.session_state.selected_notification_integration).distinct().collect()[0][0]
        else:
            notification_integration_config = ''

        notification_integration_enabled_df = session.table('NOTIFICATION_INTEGRATION').select(col('ENABLED')).filter(
            col('NAME') == st.session_state.selected_notification_integration).distinct()

        if notification_integration_enabled_df.count() > 0:
            is_enabled = notification_integration_enabled_df.collect()[0][0]
        else:
            is_enabled = True

        notification_integration_type_df = session.table('NOTIFICATION_INTEGRATION').select(col('TYPE')).filter(
            col('NAME') == st.session_state.selected_notification_integration).distinct()

        if notification_integration_type_df.count() > 0:
            notification_type = notification_integration_type_df.collect()[0][0]
        else:
            notification_type = "EMAIL"

        st.write("Selected Integration Details")

        # Template config and saving
        notification_integration_config_col1, notification_integration_config_col2 = st.columns((6, 1))

        with notification_integration_config_col1:
            is_notification_integration_enabled = st.checkbox("Is Enabled",
                                                              is_enabled,
                                                              key='is_notification_integration_enabled')

            notification_integration_type = st.selectbox("Notification Integration Type",
                                                         options=notification_integration_types,
                                                         index=notification_integration_types.index(notification_type),
                                                         key='notification_integration_type')

            notification_integration_parameters = st.text_area('Selected Notification Integration Parameters',
                                                               notification_integration_config,
                                                               height=200,
                                                               key='notification_integration_parameters',
                                                               placeholder='Enter valid JSON')

        with notification_integration_config_col2:
            st.header("")
            st.button("Save Notification Integration", on_click=save_notification_integration)
            st.button("Delete Notification Integration", on_click=delete_notification_integration)

    def print_sidebar(self):
        set_default_sidebar()


class ActionsPage(Page):
    def __init__(self):
        self.name = "Actions"

    def print_page(self):
        # Content for actions page
        # Method that a button uses to upsert an action template
        def save_action_template():
            source_df = session.create_dataframe(
                [[st.session_state['selected_action_template'], st.session_state['action_template_configuration']]],
                schema=["TEMPLATE_NAME", "TEMPLATE_CONFIGURATION"]) \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('ACTION_TEMPLATE')

            target_df.merge(
                source_df,
                (target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"]),
                [
                    when_matched().update(
                        {"TEMPLATE_CONFIGURATION": source_df["TEMPLATE_CONFIGURATION"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"TEMPLATE_NAME": source_df["TEMPLATE_NAME"],
                         "TEMPLATE_CONFIGURATION": source_df["TEMPLATE_CONFIGURATION"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            st.session_state['unique_action_template_df'] = session.table('ACTION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

            del st.session_state['selected_action_template']

        # Method that a button uses to delete an action template
        def delete_action_template():
            source_df = session.create_dataframe([st.session_state['selected_action_template']],
                                                 schema=["TEMPLATE_NAME"])
            target_df = session.table('ACTION_TEMPLATE')

            target_df.delete(target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"], source_df)

            st.session_state['unique_action_template_df'] = session.table('ACTION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

            del st.session_state['selected_action_template']

        # Remove unique_action_df sessions state
        def reset_unique_action_state(initial):
            if 'unique_action_df' in st.session_state:
                if initial != st.session_state['selected_action_template']:
                    del st.session_state['unique_action_df']

        # Method that a button uses to preview an action query
        def preview_action():
            try:
                template_config = st.session_state['action_template_configuration']
                parameter_config = sanitize(st.session_state['action_parameter_configuration'])

                preview_df = session.create_dataframe([[template_config, parameter_config]],
                                                      schema=["TEMPLATE_CONFIGURATION", "PARAMETERS_STRING"]) \
                    .with_column("PARAMETERS", parse_json(col("PARAMETERS_STRING"))) \
                    .select(call_function("GET_SQL_JINJA", [col("TEMPLATE_CONFIGURATION"), col("PARAMETERS")]))

                st.session_state['generated_action_preview'] = preview_df.collect()[0][0]
            except Exception as ex:
                st.session_state['generated_action_preview'] = "Parsing failed -\n" \
                                                               "Type: " + str(type(ex)) + "\n" \
                                                                                          "Message: " + str(ex)

        # Method that a button uses to save an action
        def save_action():
            source_df = session.create_dataframe(
                [[st.session_state['selected_action'], st.session_state['selected_action_template'],
                  sanitize(st.session_state['action_parameter_configuration'])]],
                schema=["ACTION_NAME", "TEMPLATE_NAME", "PARAMETERS_STRING"]) \
                .with_column("PARAMETERS", parse_json(col("PARAMETERS_STRING"))) \
                .drop("PARAMETERS_STRING") \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('ACTION')

            target_df.merge(
                source_df,
                ((target_df["ACTION_NAME"] == source_df["ACTION_NAME"]) &
                 (target_df["TEMPLATE_NAME"] == source_df["TEMPLATE_NAME"])),
                [
                    when_matched().update(
                        {"PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"ACTION_NAME": source_df["ACTION_NAME"],
                         "TEMPLATE_NAME": source_df["TEMPLATE_NAME"],
                         "PARAMETERS": source_df["PARAMETERS"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            st.session_state['unique_action_df'] = session.table('ACTION') \
                .filter(col('TEMPLATE_NAME') == selected_action_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ACTION_NAME')).distinct()

            del st.session_state['selected_action']

        # Method that button uses to delete an action
        def delete_action():
            source_df = session.create_dataframe([st.session_state['selected_action']], schema=["ACTION_NAME"])
            target_df = session.table('ACTION')

            target_df.delete(target_df["ACTION_NAME"] == source_df["ACTION_NAME"], source_df)

            st.session_state['unique_action_template_df'] = session.table('ACTION') \
                .filter(col('TEMPLATE_NAME') == selected_action_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ACTION_NAME')).distinct()

            del st.session_state['selected_action']

        st.title("Actions")
        st.write("Set what the alert should do when a condition is met")

        # Configured actions
        actions_df = session.table("ACTION").distinct().to_pandas()
        actions_df = actions_df.replace(r'\n', ' ', regex=True)

        with st.expander("Configured Actions"):
            st.dataframe(actions_df, use_container_width=True)

        # ------------------------ ACTION TEMPLATES ------------------------
        st.subheader("1 - Action Templates")
        st.caption("An _Action Template_ is used to define a general format of a query action")

        # Available action templates
        if 'unique_action_template_df' not in st.session_state:
            st.session_state['unique_action_template_df'] = session.table('ACTION_TEMPLATE') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('TEMPLATE_NAME')).distinct()

        unique_action_template_df = st.session_state['unique_action_template_df']

        # Template list and addition
        action_template_col1, action_template_col2 = st.columns((2, 1))

        if 'selected_action_template' not in st.session_state:
            if unique_action_template_df.count() > 0:
                st.session_state['selected_action_template'] = unique_action_template_df.collect()[0][0]
            else:
                st.session_state['selected_action_template'] = ''

        initial_action_template = st.session_state['selected_action_template']
        selection_index = 0

        with action_template_col2:
            # New action template
            with st.form("action_template_form"):
                st.write("New Action Template Entry")

                new_action_template_name = st.text_input('New Action Template Name', label_visibility='collapsed',
                                                         placeholder='New template name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new template can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_action_template_name]], schema=['TEMPLATE_NAME'])
                    unique_action_template_df = session.table('ACTION_TEMPLATE') \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col('TEMPLATE_NAME')).distinct()
                    unique_action_template_df = new_df.union_all(unique_action_template_df).distinct()
                    st.session_state['unique_action_template_df'] = unique_action_template_df

        with action_template_col1:
            selected_action_template = st.radio('Configured Action Templates', unique_action_template_df.collect(),
                                                key='selected_action_template',
                                                index=selection_index,
                                                on_change=reset_unique_action_state,
                                                args=[initial_action_template])

        # Action template config
        action_template_config_df = session.table('ACTION_TEMPLATE').select(col('TEMPLATE_CONFIGURATION')).filter(
            col('TEMPLATE_NAME') == st.session_state.selected_action_template).distinct()

        if action_template_config_df.count() > 0:
            action_template_config = session.table('ACTION_TEMPLATE').select(col('TEMPLATE_CONFIGURATION')).filter(
                col('TEMPLATE_NAME') == st.session_state.selected_action_template).distinct().collect()[0][0]
        else:
            action_template_config = ''

        # Template config and saving
        action_template_config_col1, action_template_config_col2 = st.columns((6, 1))

        with action_template_config_col1:
            action_template_configuration = st.text_area('Selected Action Template Query', action_template_config,
                                                         height=200,
                                                         key='action_template_configuration',
                                                         placeholder='Enter valid SQL or JINJA')

        with action_template_config_col2:
            st.header("")
            st.button("Save Template", on_click=save_action_template)
            st.button("Delete Template", on_click=delete_action_template)

        # ------------------------ ACTIONS ------------------------
        st.subheader("2 - Actions by Template")
        st.caption("An _Action_ is a set a parameters that, in conjunction a action template, generates a full "
                   "action query")
        st.caption("To include condition query results in your alert, add _{condition_results}_ to the _Action_")

        # Available actions
        if 'unique_action_df' not in st.session_state:
            st.session_state['unique_action_df'] = session.table('ACTION') \
                .filter(col('TEMPLATE_NAME') == selected_action_template) \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ACTION_NAME')).distinct()

        unique_action_df = st.session_state['unique_action_df']

        # List of actions
        action_col1, action_col2 = st.columns((2, 1))

        selection_index = 0

        # Form
        with action_col2:
            # New action
            with st.form("action_form"):
                st.write("New Action Entry")

                new_action_name = st.text_input('New Action Name', label_visibility='collapsed',
                                                placeholder='New action name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new action can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_action_name]], schema=['ACTION_NAME'])
                    unique_action_df = st.session_state['unique_action_df'] = session.table('ACTION') \
                        .filter(col('TEMPLATE_NAME') == selected_action_template) \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col('ACTION_NAME')).distinct()
                    unique_action_df = new_df.union_all(unique_action_df).distinct()
                    st.session_state['unique_action_df'] = unique_action_df

        # Radio list of actions
        with action_col1:
            selected_action = st.radio('Configured Actions', unique_action_df.collect(),
                                       key='selected_action',
                                       index=selection_index)

        action_parameter_col1, action_parameter_col2 = st.columns((6, 1))

        with action_parameter_col1:
            # Action parameters
            action_parameter_config_df = session.table('ACTION').select(col('PARAMETERS')) \
                .filter(col('ACTION_NAME') == st.session_state.selected_action).distinct()

            if action_parameter_config_df.count() > 0:
                action_parameter_config_df = session.table('ACTION').select(col('PARAMETERS')) \
                    .filter(col('ACTION_NAME') == st.session_state.selected_action).distinct().collect()[0][0]
            else:
                action_parameter_config_df = ''

            action_parameter_configuration = st.text_area('Selected Action Parameters', action_parameter_config_df,
                                                          height=200,
                                                          key='action_parameter_configuration',
                                                          placeholder='Enter valid JSON')

        with action_parameter_col2:
            st.header("")
            st.button("Preview Action", on_click=preview_action)
            st.button("Save Action", on_click=save_action)
            st.button("Delete Action", on_click=delete_action)

        generated_action_preview_text = ""

        if 'generated_action_preview' in st.session_state:
            generated_action_preview_text = st.session_state['generated_action_preview']

        generated_action_preview = st.text_area('Generated Preview', generated_action_preview_text,
                                                height=200,
                                                placeholder='Click Preview Action button')

    def print_sidebar(self):
        set_default_sidebar()


class AlertsPage(Page):
    def __init__(self):
        self.name = "Alerts"

    def print_page(self):
        # Content for alerts page
        # Method that a button uses to upsert an alert
        def save_alert():
            alert_name = st.session_state['selected_alert']

            source_df = session.create_dataframe(
                [[st.session_state['alert_warehouse'],
                  st.session_state['alert_schedule'],
                  alert_name,
                  st.session_state['alert_condition_name'],
                  st.session_state['alert_action_name']]],
                schema=["WAREHOUSE_NAME", "ALERT_SCHEDULE", "ALERT_NAME", "CONDITION_NAME", "ACTION_NAME"]) \
                .with_column("LAST_UPDATED_TIMESTAMP", current_timestamp())

            target_df = session.table('ALERT')

            target_df.merge(
                source_df,
                (target_df["ALERT_NAME"] == source_df["ALERT_NAME"]),
                [
                    when_matched().update(
                        {"WAREHOUSE_NAME": source_df["WAREHOUSE_NAME"],
                         "ALERT_SCHEDULE": source_df["ALERT_SCHEDULE"],
                         "CONDITION_NAME": source_df["CONDITION_NAME"],
                         "ACTION_NAME": source_df["ACTION_NAME"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    ),
                    when_not_matched().insert(
                        {"WAREHOUSE_NAME": source_df["WAREHOUSE_NAME"],
                         "ALERT_SCHEDULE": source_df["ALERT_SCHEDULE"],
                         "ALERT_NAME": source_df["ALERT_NAME"],
                         "CONDITION_NAME": source_df["CONDITION_NAME"],
                         "ACTION_NAME": source_df["ACTION_NAME"],
                         "LAST_UPDATED_TIMESTAMP": source_df["LAST_UPDATED_TIMESTAMP"]}
                    )
                ]
            )

            session.call("deploy_alert", alert_name)

            st.session_state['unique_alert_df'] = session.table('ALERT') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ALERT_NAME')).distinct()

            del st.session_state['selected_alert']

        # Method that a button uses to delete an alert
        def delete_alert():
            alert_name = st.session_state['selected_alert']

            sql_text = "drop alert if exists {alert_name};".format(alert_name=alert_name)

            # Drop alert
            session.sql(sql_text).collect()

            # Drop ALERT record
            source_df = session.create_dataframe([alert_name], schema=["ALERT_NAME"])
            target_df = session.table('ALERT')

            target_df.delete(target_df["ALERT_NAME"] == source_df["ALERT_NAME"], source_df)

            st.session_state['unique_alert_df'] = session.table('ALERT') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ALERT_NAME')).distinct()

            del st.session_state['selected_alert']

        # Remove unique_alert_df sessions state
        def reset_unique_alert_state(initial):
            if 'unique_alert_df' in st.session_state:
                if initial != st.session_state['selected_alert']:
                    del st.session_state['unique_alert_df']

        # Method that a button uses to toggle an alert
        def toggle_alert(action):
            alert_name = st.session_state['selected_alert']

            sql_text = "alter alert {alert_name} {action};".format(alert_name=alert_name, action=action)

            # Alter alert
            session.sql(sql_text).collect()

        st.title("Alerts")
        st.write("Configure and deploy the alerts to Snowflake")
        st.write("[Official Documentation](https://docs.snowflake.com/guides-overview-alerts)")

        # Deployed alerts
        deployed_alerts_df = session.sql('show alerts').select(col('"name"').alias('name'), col('"state"').alias('state')).distinct()

        # Configured alerts
        configured_alerts_df = session.table("ALERT").sort(col('LAST_UPDATED_TIMESTAMP').desc()).distinct()

        # Join configured and deployed alerts to get status
        alerts_df = configured_alerts_df \
            .join(deployed_alerts_df, upper(configured_alerts_df["ALERT_NAME"]) == deployed_alerts_df["name"]) \
            .select(configured_alerts_df["ALERT_NAME"], deployed_alerts_df["state"],
                    configured_alerts_df["WAREHOUSE_NAME"],
                    configured_alerts_df["ALERT_SCHEDULE"], configured_alerts_df["CONDITION_NAME"],
                    configured_alerts_df["ACTION_NAME"], configured_alerts_df["LAST_UPDATED_TIMESTAMP"])

        # Replace any new lines for better dataframe rendering
        alerts_pandas_df = alerts_df.to_pandas()
        alerts_df = alerts_pandas_df.replace(r'\n', ' ', regex=True)

        # Replace with editable dataframe when available in SiS
        with st.expander("Configured Alerts", expanded=True):
            st.dataframe(alerts_df, use_container_width=True)

        # Available alerts
        if 'unique_alert_df' not in st.session_state:
            st.session_state['unique_alert_df'] = session.table('ALERT') \
                .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                .select(col('ALERT_NAME')).distinct()

        unique_alert_df = st.session_state['unique_alert_df']

        # Integration list and addition
        alert_col1, alert_col2 = st.columns((2, 1))

        if 'selected_alert' not in st.session_state:
            if unique_alert_df.count() > 0:
                st.session_state['selected_alert'] = unique_alert_df.collect()[0][0]
            else:
                st.session_state['selected_alert'] = ''

        initial_alert = st.session_state['selected_alert']
        selection_index = 0

        with alert_col2:
            # New action template
            with st.form("alert_form"):
                st.write("New Alert Entry")

                new_alert_name = st.text_input('New Alert Name',
                                               label_visibility='collapsed',
                                               placeholder='New alert name')

                submitted = st.form_submit_button('Create New')

                st.info("Note - Only one new alert can be added prior to saving")

                if submitted:
                    new_df = session.create_dataframe([[new_alert_name.replace(" ", "_")]], schema=['ALERT_NAME'])
                    unique_alert_df = session.table("ALERT") \
                        .sort(col('LAST_UPDATED_TIMESTAMP').desc()) \
                        .select(col("ALERT_NAME")).distinct()
                    unique_alert_df = new_df.union_all(unique_alert_df).distinct()
                    st.session_state['unique_alert_df'] = unique_alert_df

        with alert_col1:
            selected_alert = st.radio('Configured Alerts',
                                      unique_alert_df.collect(),
                                      key='selected_alert',
                                      index=selection_index,
                                      on_change=reset_unique_alert_state,
                                      args=[initial_alert])

        # Condition and Action options
        condition_options = session.table('CONDITION').select(col('CONDITION_NAME')).distinct().to_pandas()[
            'CONDITION_NAME'].values.tolist()
        action_options = session.table('ACTION').select(col('ACTION_NAME')).distinct().to_pandas()[
            'ACTION_NAME'].values.tolist()

        condition_index = 0
        action_index = 0

        # Get alert details
        if selected_alert:
            alert_status_df = session.sql('show alerts').filter(col('"name"') == st.session_state.selected_alert.upper())\
                .select(col('"state"').alias('state')).distinct()
        else:
            alert_status_df = session.sql('show alerts').filter(
                col('"name"') == "") \
                .select(col('"state"').alias('state')).distinct()

        if alert_status_df.count() > 0:
            if alert_status_df.collect()[0][0] == 'started':
                current_alert_is_enabled = True
            else:
                current_alert_is_enabled = False
        else:
            current_alert_is_enabled = False

        alert_warehouse_df = session.table('ALERT').select(col('WAREHOUSE_NAME')).filter(
            col('ALERT_NAME') == st.session_state.selected_alert).distinct()

        if alert_warehouse_df.count() > 0:
            current_alert_warehouse = alert_warehouse_df.collect()[0][0]
        else:
            current_alert_warehouse = "alerts_wh"

        alert_schedule_df = session.table('ALERT').select(col('ALERT_SCHEDULE')).filter(
            col('ALERT_NAME') == st.session_state.selected_alert).distinct()

        if alert_schedule_df.count() > 0:
            current_alert_schedule = alert_schedule_df.collect()[0][0]
        else:
            current_alert_schedule = "1 MINUTE"

        alert_condition_name_df = session.table('ALERT').select(col('CONDITION_NAME')).filter(
            col('ALERT_NAME') == st.session_state.selected_alert).distinct()

        if alert_condition_name_df.count() > 0:
            current_alert_condition_name = alert_condition_name_df.collect()[0][0]
            condition_index = condition_options.index(current_alert_condition_name)
        else:
            current_alert_condition_name = ""

        alert_action_name_df = session.table('ALERT').select(col('ACTION_NAME')).filter(
            col('ALERT_NAME') == st.session_state.selected_alert).distinct()

        if alert_action_name_df.count() > 0:
            current_alert_action_name = alert_action_name_df.collect()[0][0]
            action_index = action_options.index(current_alert_action_name)
        else:
            current_alert_action_name = ""

        st.write("Selected Alert Details")

        # Template config and saving
        alert_config_col1, alert_config_col2 = st.columns((6, 1))

        with alert_config_col1:
            alert_status = st.checkbox("Alert Is Enabled", current_alert_is_enabled, disabled=True,
                                       help="Use Resume/Suspend buttons to change")
            alert_warehouse = st.text_input("Warehouse", current_alert_warehouse, key='alert_warehouse')
            alert_schedule = st.text_input("Schedule", current_alert_schedule, help="MINUTES or CRON formats accepted",
                                           key='alert_schedule')
            alert_condition_name = st.selectbox("Condition Name", options=condition_options, index=condition_index,
                                                key='alert_condition_name')
            alert_action_name = st.selectbox("Action Name", options=action_options, index=action_index,
                                             key='alert_action_name')

        with alert_config_col2:
            st.header("")
            st.button("Save Alert", on_click=save_alert)
            st.button("Resume Alert", on_click=toggle_alert, args=['resume'])
            st.button("Suspend Alert", on_click=toggle_alert, args=['suspend'])
            st.button("Delete Alert", on_click=delete_alert)

    def print_sidebar(self):
        set_default_sidebar()


pages = [WelcomePage(), ConditionsPage(), NotificationIntegrationsPage(), ActionsPage(), AlertsPage()]


def main():
    for page in pages:
        if page.name == st.session_state.page:
            page.print_page()
            page.print_sidebar()


main()
$$
);

call alert_hub.deployment.put_to_stage('streamlit_stage', 'streamlit_ui.py', (select script from alert_hub.deployment.script where name = 'streamlit'));

create or replace streamlit alert_hub.admin.alert_hub
    root_location = '@alert_hub.deployment.streamlit_stage'
    main_file = '/streamlit_ui.py'
    query_warehouse = 'alerts_wh'
    comment='{"origin":"sf_sit","name":"alert_hub","version":{"major":1, "minor":0},"attributes":{"component":"alert_hub"}}'
;
