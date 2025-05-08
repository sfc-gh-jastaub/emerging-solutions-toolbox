import pickle

func = pickle.loads(bytes.fromhex('800595b61c0000000000008c17636c6f75647069636b6c652e636c6f75647069636b6c65948c0e5f6d616b655f66756e6374696f6e9493942868008c0d5f6275696c74696e5f747970659493948c08436f6465547970659485945294284b034b004b004b2e4b0f4b03423c0600007400a001a1007d037c03a0026401a1017d047403a00464026403a1027d057c0172667c00a00574069b00640474079b009d03a101a0087409a00a6405a1017409a00b7c01a1016b027409a00a6406a10164076b024000a1017d067c06a00c6405a101a00d7409a00e6408a101a00f6409a101a1016a107c0664056701640a640b8d03a0087409a00a6408a1017409a00a6409a1016b02a101a011a1007d077c0772617c07640c1900640819007d087412a0137c07640c1900640d1900a1017d026e077c01640e640f9c02530064107d087c0264111900640417007c02641219001700640417007c026413190017007d097c02641419007d0a7c026415190089057c02641619007d0b7c0b64007500728a67007d0b6417641884007c0264191900440083017d0c641a641884007c0264191900440083017d0d69007c0ca5017c0da5017d0e641b641884007c0264191900440083017d0f69007c0ea5017c0fa5017d0e641c641d84007c0264191900440083017d107c02641e19007d117c08640c6b0572db7c02641f19007d127c02642019007d137c119b0064047c129b0064047c139b009d057d147c00a0057c14a1016a147d156e1864217d1264227c049b0064237c059b009d047d137c119b0064047c129b0064047c139b009d057d1467006424a2017d157c00a0057c09a1017d167c0a900172037c16a0087409a0157c0aa101a1017d167c16a01664257c049b009d0274096a177c0b8e00a1027d167c006a1867006426a20167017419a01a7419a01b64277419a01ca100a1027419a01b64287419a01da100a1027419a01b64297419a01ea100a1027419a01b642a7419a01fa100a1027419a01b642b7419a020a100a1027419a01b642c7419a021642da101a1026706a101642e8d02a0087409a00a6427a101a022a100a1017d17642f7c107600900272e47c0e643019007d187c0e6431190089037c0e64321900640c19007d1974237c1974248302900172717c19a025a10064336b029001727164007d197c16a026880564257c049b009d02670117007c181700a1017d1a74277c1a7c1883025c037d1b89017d1c870166016434641d84087c18440083017d1d7c1d7c1c170089007c1b6a1489027c1844005d0d7d1e7c1ba0087409a00a7c1ea101a022a100a1017d1b90017198643574286a29643674286a2966048700870287038705660464376438840c8904742a7c0b8301640c6b02900172fe64397d1f742b6a2c6455643a880069018803a4018e017d207c20a02d7c1ba10101007c206a2e7c1b643b643c8d027d217c21a0268805643b67011700a101a016642a7409a00b6410a1017409a00a643ba1017409a00b643da10118001400a102a02f643ba1017d227c22a01664257c049b009d027409a00b6700a101a1027d226e8c643e641d84007c1b6a306a31440083017d237419a0327c23a10167017d247c1ba026643f641d8400880544008301a1016a306a317d256440641d84007c25440083017419a01fa100670117007d266441641d84007c2544008301642a670117007d277419a0327c267c27a1027d2874339b0064427c049b0064437c059b009d057d1f470087046601644464458408644583027d297c006a346a357c297c287c247c1f644674339b00640474369b009d04640767006447a201640764488d0801007409a0377c1fa1017d2a7c1ba02664257c049b009d0267017c2a6449641d84008802440083018e006a3864257c049b009d0267018805644a8d0267011700a1017d2b7c2ba026644b641d84007c2b6a1444008301a1017d22644c641d84008805440083017d2c7c22a039644d74096a3a7c2c8e00a1027d227c22a0267409a00b642fa101a00f6427a1017409a00a64257c049b009d02a101a00f6428a1017409a00a644da101a00f6429a101642aa1047d227c22a016642b7409a03b7409a00a642aa1017409a00b7c19a1016b04644ea102a03c640ca101a102a016642c7409a03b7409a00a642ba101644e6b027409a00b644fa101a102a03c6400a101a1027d227c17a03d7c22a1017d177c17a0267409a00b7c08a101a00f6408a1017409a00b7c03a101a00f6450a101642764287409a00b7c09a101a00f6451a1016429642a642b642ca109a0267c15a101a03e64276428642aa1037d2d7c2d6a3f6a407c14645264538d0201007c147c117c127c137c017c087c0b7c1f64549c08530094284e8c1125595f256d5f25645f25485f254d5f2553944de8034d28238c012e948c084a4f425f4e414d45948c0949535f41435449564594888c064a4f425f4944948c0a4d41585f4a4f425f4944948c05696e6e6572948c026f6e948c03686f779486944b008c094a4f425f5350454353948c1d4e6f20616374697665206a6f627320776974682074686174206e616d6594680b8c054552524f529486944affffffff8c0f5441424c455f425f44425f4e414d45948c135441424c455f425f534348454d415f4e414d45948c0c5441424c455f425f4e414d45948c0e5441424c455f425f46494c544552948c195441424c455f425f5245434f52445f49445f434f4c554d4e53948c195441424c455f425f504152544954494f4e5f434f4c554d4e53946807284b014b004b004b024b054b53432269007c005d0d7d0164007c01640119009b0064029d037c016403190093027102530094288c05636865636b948c0d434845434b5f545950455f4944948c085f636f6c756d6e73948c0f5441424c455f425f434f4c554d4e53947494298c022e3094681e86948c4e2f7661722f666f6c646572732f36792f707a76747433343937717131376d6c303974675f686d763430303030676e2f542f6970796b65726e656c5f32303339302f333531373532353732302e7079948c0a3c64696374636f6d703e944b3d43080600020214ff06ff942929749452948c2b616e6f6d616c795f646574656374696f6e5f7370726f632e3c6c6f63616c733e2e3c64696374636f6d703e948c06434845434b53946807284b014b004b004b024b054b53681d28681e681f8c105f6879706572706172616d5f64696374948c144859504552504152414d45544552535f44494354947494296824682568264b4268272929749452946807284b014b004b004b024b054b53681d28681e681f8c0b5f7468726573686f6c6473948c0f414c4552545f5448524553484f4c44947494296824682568264b4d68272929749452946807284b014b004b004b024b044b53431467007c005d067d017c016400190091027102530094681f859429682468258c0a3c6c697374636f6d703e944b5743021400942929749452948c2b616e6f6d616c795f646574656374696f6e5f7370726f632e3c6c6f63616c733e2e3c6c697374636f6d703e948c0a524553554c54535f4442948c0e524553554c54535f534348454d41948c0e524553554c54535f54424c5f4e4d948c1454454d504f524152595f44515f4f424a45435453948c0554454d505f948c155f414e4f4d5f4445544543545f524553554c54535f9428680d8c0c52554e5f4441544554494d4594681f8c10504152544954494f4e5f56414c554553948c0c434845434b5f54424c5f4e4d948c0a5245434f52445f494453948c0d414e4f4d414c595f53434f5245948c0a414c4552545f464c4147948c0c414c4552545f5354415455539474948c11504152544954494f4e5f56414c5545535f94284e4e4e4e4e4e7494681f684468466847684868494bc88c06736368656d619485944b088c0e636865636b385f636f6c756d6e73948c16636865636b385f6879706572706172616d5f64696374948c11636865636b385f7468726573686f6c6473948c044e554c4c946807284b014b004b004b024b044b13431867007c005d087d017c018800760172027c0191027102530094292968238c06636f6c756d6e948694682568384bae430406001201948c1343415445474f524943414c5f434f4c554d4e5394859429749452948c1570616e6461735f7472616e73666f726d65645f6466948c0672657475726e946807284b014b004b004b054b054b13436c88017c005f007c00880019007d017401640569008802a4018e017d027c02a0027c01a10101007c02a0037c01a1017d0374046a057c00880319007404a0067c03a1016702640164028d027d0488036403670117007c045f0064047c046403190014007c0464033c007c04530094284e4b018c046178697394859468474affffffff297494288c07636f6c756d6e73948c0f49736f6c6174696f6e466f72657374948c03666974948c0d73636f72655f73616d706c6573948c027064948c06636f6e636174948c09446174614672616d6594749428685b8c026466948c1069736f6c6174696f6e5f666f72657374948c0673636f726573948c0964665f73636f72656494749468258c19706572666f726d5f616e6f6d616c795f646574656374696f6e944bbb4322060408030e030a030403020104ff04050602080102fe020406fb0c070a0206ff040494288c19414e4f4d414c595f444554454354494f4e5f434f4c554d4e53948c0f696e7075745f636f6c5f6e616d6573948c0f706172616d65746572735f64696374948c0e7265636f72645f69645f636f6c7394749429749452948c3a616e6f6d616c795f646574656374696f6e5f7370726f632e3c6c6f63616c733e2e706572666f726d5f616e6f6d616c795f646574656374696f6e948c00948c0a696e7075745f636f6c73948c0e4445434953494f4e5f46554e435f948c126f75747075745f636f6c735f707265666978948594473fe00000000000006807284b014b004b004b024b034b53431267007c005d057d017c016a0091027102530094298c08646174617479706594859468238c056669656c64948694682568384d300143021200942929749452946807284b014b004b004b024b064b53432067007c005d0c7d017400a0017c01a101a00264007c011700a101910271025300948c0a5f5f4f55545055545f5f9485948c0146948c03636f6c948c05616c69617394879468238c06636f6c5f6e6d948694682568384d340143080600020212ff06ff942929749452946807284b014b004b004b024b034b53687d29687f6881682568384d3a0143060600060106ff942929749452946807284b014b004b004b024b034b53687d298c046e616d659485946881682568384d3e0168912929749452948c182e706572666f726d5f616e6f6d5f646574656374696f6e5f948c065f756474665f946807284b004b004b004b004b034b00431865005a0164005a02870066016401640284085a036403530094288c2f616e6f6d616c795f646574656374696f6e5f7370726f632e3c6c6f63616c733e2e616e6f6d5f646574656374696f6e946807284b024b004b004b034b024b334314810088007c0183017d027c025600010064005300944e8594298c0473656c669468698c0866696e616c5f646694879468258c0d656e645f706172746974696f6e944d4a014306028008010a0194686e859429749452948c3d616e6f6d616c795f646574656374696f6e5f7370726f632e3c6c6f63616c733e2e616e6f6d5f646574656374696f6e2e656e645f706172746974696f6e944e7494288c085f5f6e616d655f5f948c0a5f5f6d6f64756c655f5f948c0c5f5f7175616c6e616d655f5f9468a174942968258c0e616e6f6d5f646574656374696f6e944d49014304080010019468a3297494529468ac8c0140948c19736e6f77666c616b652d736e6f777061726b2d707974686f6e948c0670616e646173948c0c7363696b69742d6c6561726e948794288c0d6f75747075745f736368656d61948c0b696e7075745f74797065739468948c0e73746167655f6c6f636174696f6e948c0c69735f7065726d616e656e74948c087061636b61676573948c077265706c6163659474946807284b014b004b004b024b054b53431667007c005d077d017400a0017c01a1019102710253009429688868898694688d682568384d5f0143021600942929749452948c0c706172746974696f6e5f6279948c086f726465725f62799486946807284b014b004b004b024b074b53433267007c005d157d017c01a0006400a10172157401a0027c01a101a0037c016401640285021900a1016e017c019102710253009468864b0a4e8794288c0a737461727473776974689468886889688a7494688d682568384d6901430c0600020608fd1aff020206fc942929749452946807284b014b004b004b034b064b53432a67007c005d117d017400a0017c01a1017400a0027c01a101660244005d047d027c029103710e71025300942968888c036c6974946889879468238c05636f6c6e6d948c046974656d948794682568384d7601430a0600140104ff040108ff942929749452948c0b5245434f52445f44494354944b018c0e70656e64696e672072657669657794684368458c06617070656e64948c046d6f6465948594288c175155414c49464945445f524553554c545f54424c5f4e4d948c09524553554c545f4442948c0d524553554c545f534348454d41948c0d524553554c545f54424c5f4e4d94680b680d8c11504152544954494f4e5f434f4c554d4e53948c07554454465f4e4d947494297494288c086461746574696d65948c036e6f77948c087374726674696d65948c0672616e646f6d948c0772616e64696e74948c057461626c65948c0d636f6e6669675f736368656d61948c0b6a6f62735f74626c5f6e6d948c0666696c746572946888688968cc8c0767726f75704279948c03616767948c036d617894688a8c046a6f696e948c07636f6c6c656374948c046a736f6e948c056c6f6164739468618c0465787072948c0b776974685f636f6c756d6e948c0f61727261795f636f6e737472756374948c106372656174655f646174616672616d65948c0154948c0a53747275637454797065948c0b5374727563744669656c64948c0b496e746567657254797065948c09417272617954797065948c0b56617269616e7454797065948c09466c6f617454797065948c084c6f6e6754797065948c0a537472696e6754797065948c0969734e6f744e756c6c948c0a6973696e7374616e6365948c03737472948c057570706572948c0673656c656374948c1f616e6f6d616c795f646574656374696f6e5f70726570726f63657373696e6794686568678c036c656e948c03736d6c94686268638c116465636973696f6e5f66756e6374696f6e948c0464726f7094684d8c066669656c6473948c1350616e646173446174614672616d6554797065948c1374656d705f6f626a656374735f736368656d61948c0475647466948c087265676973746572948c0f74656d705f66696c655f7374616765948c0e7461626c655f66756e6374696f6e948c046f766572948c0a77697468436f6c756d6e948c1a6f626a6563745f636f6e7374727563745f6b6565705f6e756c6c948c047768656e948c096f7468657277697365948c11756e696f6e5f616c6c5f62795f6e616d65948c04736f7274948c057772697465948c0d736176655f61735f7461626c65947494288c0773657373696f6e948c066a6f625f6e6d948c096a6f625f7370656373948c0872756e5f6474746d948c0c72756e5f6474746d5f737472948c0d72616e646f6d5f6e756d626572948c106163746976655f7265636f72645f6466948c0a6a6f625f7265636f7264948c066a6f625f6964948c187175616c69666965645f696e7075745f7461626c655f6e6d948c0e73716c5f66696c7465725f737472948c0e706172746974696f6e5f636f6c73948c0e636865636b735f636f6c756d6e73948c106879706572706172616d5f6469637473948c0b636865636b5f7370656373948c10616c6572745f7468726573686f6c6473948c0d636865636b5f69645f6c697374948c0a726573756c74735f6462948c0e726573756c74735f736368656d61948c0e726573756c74735f74626c5f6e6d948c177175616c69666965645f726573756c745f74626c5f6e6d948c13726573756c74735f74626c5f636f6c756d6e73948c087364665f62617365948c0f756e696f6e65645f726573756c7473948c10434f4c554d4e535f544f5f434845434b948c15616c6572745f7468726573686f6c645f76616c7565948c03736466948c0e7472616e73666f726d65645f6466948c0b4e45575f434f4c554d4e53948c174e4f4e5f43415445474f524943414c5f434f4c554d4e539468548c07756474665f6e6d94686a686b8c09726573756c745f6466948c0c696e7075745f647479706573948c16766563745f756474665f696e7075745f647479706573948c176f75745f72656e616d65645f6669656c64735f6c697374948c19766563745f756474665f6f75745f6474797065735f6c697374948c1c766563745f756474665f6f75745f636f6c5f6e616d65735f6c697374948c17766563745f756474665f6f75747075745f736368656d619468ac8c055f75647466948c0a7364665f73636f726564948c0749445f4c495354948c097364665f66696e616c94749468258c17616e6f6d616c795f646574656374696f6e5f7370726f63944b0142b001000008070a010c0104031202240102fe0206060112010a0104fd1604040102fa040a0c0114010204020106fe04050609020102ff060202fe020302fd060402fc02ff080808010801080104010602060206fe0605060206fe0c050606060206fe0c051205080308020801080114010e0104021001140108010a11060310010403100104ff0407080104010e020e010e010e010e01100102fa02ff04fe100c02f40a14080308010c011a0104010403120104ff080902fc0201020102010a04020106ff08030603080318010203040102ff040214fe0e24040214130a020e020402080102ff020202011c0102fe0203020102ff02fb0409100106ff122d0c0104020601020204fe02ff040502fb0607020104ff080204fe0604020104ff040204fe0404040104ff14051202060502010201020102010e0102010601020106f80a0c04020a0112020a01020104fe02ff02ff04ff040c0601040604fa04ff060e020106ff04030a0104ff04040e0114010e01020104fc020c2601260102fd0a0804080e010e01020102010e01020102010201020102f7020b020102ff0a0302f110130203020102010201020102010201020106f89429286870685768716872686e68737494749452947d94288c0b5f5f7061636b6167655f5f944e68a88c085f5f6d61696e5f5f94754e4e4e749452948c1c636c6f75647069636b6c652e636c6f75647069636b6c655f66617374948c125f66756e6374696f6e5f73657473746174659493946a4d0100007d947d942868a86a4401000068aa6a440100008c0f5f5f616e6e6f746174696f6e735f5f947d948c0e5f5f6b7764656661756c74735f5f944e8c0c5f5f64656661756c74735f5f944e68a96a4b0100008c075f5f646f635f5f944e8c0b5f5f636c6f737572655f5f944e8c175f636c6f75647069636b6c655f7375626d6f64756c6573945d948c0b5f5f676c6f62616c735f5f947d942868e168e18c086461746574696d6594939468e468008c09737562696d706f727494939468e48594529468e78c06434f4e4649479468e88c0744515f4a4f42539468886a600100008c1c736e6f77666c616b652e736e6f777061726b2e66756e6374696f6e73948594529468ef6a6001000068ef8594529468f56a600100008c18736e6f77666c616b652e736e6f777061726b2e747970657394859452946a030100008c117574696c6974795f66756e6374696f6e73946a03010000939468656a6001000068b2859452946a050100006a600100008c1e736e6f77666c616b652e6d6c2e6d6f64656c696e672e656e73656d626c6594859452946a0a01000068406a0d0100008c04434f44459468628c19736b6c6561726e2e656e73656d626c652e5f69666f726573749468629394757586948652302e'))
# The following comment contains the source code generated by snowpark-python for explanatory purposes.
# import json
# import pandas as pd
# import random
# import snowflake.ml.modeling.ensemble as sml
# import snowflake.snowpark.functions as F
# import snowflake.snowpark.types as T
# from datetime import datetime
# from sklearn.ensemble._iforest import IsolationForest
# from utility_functions import anomaly_detection_preprocessing
# temp_file_stage  # variable of type <class 'str'>
# temp_objects_schema  # variable of type <class 'str'>
# config_schema  # variable of type <class 'str'>
# jobs_tbl_nm  # variable of type <class 'str'>
# def anomaly_detection_sproc(
#     session: Session,
#     job_nm: str,
#     job_specs: dict
# ) -> dict:
#
#     # Create a string of the current datetime. This will be used to name temporary objects will also be stored in results table.
#     run_dttm = datetime.now()
#     run_dttm_str = run_dttm.strftime("%Y_%m_%d_%H_%M_%S")
#     random_number = random.randint(1000, 9000)
#
#     # If a valid JOB_NAME is provided, procure the most current JOB_ID and JOB_SPECS for that job
#     if job_nm:
#         active_record_df = (
#             session.table(f"{config_schema}.{jobs_tbl_nm}")
#             .filter((F.col("JOB_NAME") == F.lit(job_nm)) & (F.col("IS_ACTIVE") == True))
#         )  # Obtain the ACTIVE Record for that JOB_NAME 
#
#         job_record = (
#             active_record_df
#             .groupBy("JOB_NAME")
#             .agg(F.max("JOB_ID").alias("MAX_JOB_ID"))
#             .join(active_record_df, on=["JOB_NAME"], how='inner')
#             .filter(F.col("JOB_ID")==F.col("MAX_JOB_ID"))
#             .collect()
#         ) # In the unexpected event that there is somehow more than one ACTIVE record for the given JOB_NAME, take the highest JOB_ID number
#
#         # If an active job is found in the DQ_JOBS table then get the JOB_ID and JOB_SPECS dictionary
#         if job_record:
#             job_id = job_record[0]["JOB_ID"]
#             job_specs = json.loads(job_record[0]["JOB_SPECS"])
#         else:
#             # If there were no active jobs in the DQ_JOBS table, then job_record will be an empty list. 
#             return {
#                 "JOB_NAME": job_nm,
#                 "ERROR": 'No active jobs with that name'
#             }
#     else:
#         job_id = -1
#
#
#
#     # *****************************************************
#     # Extract variable values from job_specs dictionary
#     # *****************************************************
#
#     qualified_input_table_nm = (
#         job_specs["TABLE_B_DB_NAME"]
#         + "."
#         + job_specs["TABLE_B_SCHEMA_NAME"]
#         + "."
#         + job_specs["TABLE_B_NAME"]
#     )
#
#     sql_filter_str = job_specs["TABLE_B_FILTER"]
#     record_id_cols = job_specs["TABLE_B_RECORD_ID_COLUMNS"]
#     partition_cols = job_specs["TABLE_B_PARTITION_COLUMNS"]
#     if partition_cols is None:
#         partition_cols = []
#
#     checks_columns = {
#         f'check{check["CHECK_TYPE_ID"]}_columns': check["TABLE_B_COLUMNS"]
#         for check in job_specs["CHECKS"]
#     }
#
#     hyperparam_dicts = {
#         f'check{check["CHECK_TYPE_ID"]}_hyperparam_dict': check["HYPERPARAMETERS_DICT"]
#         for check in job_specs["CHECKS"]
#     }
#
#     check_specs = {**checks_columns, **hyperparam_dicts}
#
#
#     # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#     # ALERT THRESHOLDS
#     # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#     alert_thresholds = {
#         f'check{check["CHECK_TYPE_ID"]}_thresholds': check["ALERT_THRESHOLD"]
#         for check in job_specs["CHECKS"]
#     }
#
#     check_specs = {**check_specs, **alert_thresholds}
#     # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#
#
#     # Create a list of check ids for the given job. This will be used to only run checks that are in the list
#     check_id_list = [check["CHECK_TYPE_ID"] for check in job_specs["CHECKS"]]
#
#     # # Specify where to write the results
#     results_db = job_specs["RESULTS_DB"]
#
#     if job_id >= 0:
#         results_schema = job_specs["RESULTS_SCHEMA"]
#         results_tbl_nm = job_specs["RESULTS_TBL_NM"]
#         qualified_result_tbl_nm = f"{results_db}.{results_schema}.{results_tbl_nm}"
#         results_tbl_columns = session.table(qualified_result_tbl_nm).columns
#     else:
#         results_schema = "TEMPORARY_DQ_OBJECTS"
#         results_tbl_nm = f"TEMP_{run_dttm_str}_ANOM_DETECT_RESULTS_{random_number}"
#         qualified_result_tbl_nm = f"{results_db}.{results_schema}.{results_tbl_nm}"
#         results_tbl_columns = [
#             "JOB_ID",
#             "RUN_DATETIME",
#             "CHECK_TYPE_ID",
#             "PARTITION_VALUES",
#             "CHECK_TBL_NM",
#             "RECORD_IDS",
#             "ANOMALY_SCORE",
#             "ALERT_FLAG", # NOTE: Added ALERT_FLAG and ALERT_STATUS to the results tables # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#             "ALERT_STATUS" # NOTE: Added ALERT_FLAG and ALERT_STATUS to the results tables # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#         ]
#
#     # *****************************************************
#     # Create input dataframe and shell df for results
#     # *****************************************************
#
#     # Create Snowpark DataFrame
#     sdf_base = session.table(qualified_input_table_nm)
#
#     # Filter the table based on desired filter conditions
#     if sql_filter_str:
#         sdf_base = sdf_base.filter(F.expr(sql_filter_str))
#
#     # Add an ARRAY column that holds the partion values (name it something unique in case the input table already has a column called "PARTITION_VALUES")
#     sdf_base = sdf_base.with_column(
#         f"PARTITION_VALUES_{run_dttm_str}", F.array_construct(*partition_cols)
#     )
#
#     # Create an empty DataFrame to hold all the results from all anomaly detection algorithms
#     #    (this is important if more than one algorithm is selected, but in practice there will probably only be one anomaly detection algorithm selected for a given job)
#     # NOTE: Added ALERT_FLAG and ALERT_STATUS to the results tables # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#     unioned_results = session.create_dataframe(
#         [[None, None, None, None, None, None]], # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#         schema=T.StructType(
#             [
#                 T.StructField("CHECK_TYPE_ID", T.IntegerType()),
#                 T.StructField("PARTITION_VALUES", T.ArrayType()),
#                 T.StructField("RECORD_IDS", T.VariantType()),
#                 T.StructField("ANOMALY_SCORE", T.FloatType()),
#                 T.StructField("ALERT_FLAG", T.LongType()), # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#                 T.StructField("ALERT_STATUS", T.StringType(200)) # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#             ]
#         ),
#     ).filter(F.col("CHECK_TYPE_ID").isNotNull())
#
#
#     # *****************************************************
#     # Perform Anomaly Detection
#     # *****************************************************
#
#     if (
#         8 in check_id_list
#     ):  # TODO future version: Maybe save a sproc for each check, and this pulls the correct sproc name from the DQ_JOBS table (instead of these if blocks)
#         # Establish columns this check will analyze and the hyperparameter dictionary for he isolation forest algorithm
#         COLUMNS_TO_CHECK = check_specs["check8_columns"]
#         parameters_dict = check_specs["check8_hyperparam_dict"]
#         alert_threshold_value = check_specs["check8_thresholds"][0]
#         if isinstance(alert_threshold_value, str) and alert_threshold_value.upper() == 'NULL':
#             alert_threshold_value = None
#
#         # Only keep relevant columns
#         sdf = sdf_base.select(
#             record_id_cols + [f"PARTITION_VALUES_{run_dttm_str}"] + COLUMNS_TO_CHECK
#         )
#
#         # Perform preprocessing
#         (
#             transformed_df,
#             CATEGORICAL_COLUMNS,
#             NEW_COLUMNS,
#         ) = anomaly_detection_preprocessing(sdf, COLUMNS_TO_CHECK)
#
#         # After pre-processing, change the list of columns to analyze by replacing any CATEGORICAL columns with their one-hot-encoded counterparts
#         NON_CATEGORICAL_COLUMNS = [
#             column for column in COLUMNS_TO_CHECK if column not in CATEGORICAL_COLUMNS
#         ]
#         ANOMALY_DETECTION_COLUMNS = NON_CATEGORICAL_COLUMNS + NEW_COLUMNS
#
#         # Obtain list of column names in the transformed DataFrame
#         input_col_names = transformed_df.columns
#
#         # Handle NULL values (remove records with null values)
#         for column in COLUMNS_TO_CHECK:
#             transformed_df = transformed_df.filter(F.col(column).isNotNull())
#
#         # Define a function that performs anomaly detection.
#         def perform_anomaly_detection(
#             pandas_transformed_df: pd.DataFrame,
#         ) -> pd.DataFrame:
#             # Ensure that the columns are named correctly (needed for applyInPandas)
#             pandas_transformed_df.columns = input_col_names
#
#             # For modeling, only keep the columns of interest
#             df = pandas_transformed_df[ANOMALY_DETECTION_COLUMNS]
#
#             # Create isolation forest object
#             isolation_forest = IsolationForest(**parameters_dict)
#
#             # Fit a model
#             isolation_forest.fit(df)
#
#             # Score the dataframe
#             scores = isolation_forest.score_samples(
#                 df
#             )  # NOTE: score_samples provides negative scores, where larger magnitude means more anomalous
#
#             # Re-format scores and join to original dataset
#             df_scored = pd.concat(
#                 [
#                     pandas_transformed_df[record_id_cols],
#                     pd.DataFrame(scores),
#                 ],
#                 axis=1,
#             )  # Join the IsolationForest scores to the original dataframe
#             df_scored.columns = record_id_cols + ["ANOMALY_SCORE"]
#             df_scored["ANOMALY_SCORE"] = (
#                 -1 * df_scored["ANOMALY_SCORE"]
#             )  # Invert the sign of the score so that larger positive numbers indicate more anomalous records
#
#             return df_scored
#
#         # If there are no partition columns then build a single model directly in this sproc. Otherwise use UDTF to run the models for each partition in parallel.
#         if len(partition_cols) == 0:
#             # Without partitions, no udtf is needed
#             udtf_nm = ""
#
#             # # # **** Using Sklearn instead of Snowpark ML **** 
#             # # Convert to a pandas dataframe
#             # pandas_transformed_df = (
#             #     transformed_df.to_pandas()
#             # )  # NOTE: Uncomment this line if not sorting.
#
#             # # Perform anomaly detection
#             # df_scored = perform_anomaly_detection(pandas_transformed_df)
#
#             # # Convert back to a Snowpark DataFrame
#             # result_df = session.create_dataframe(df_scored)
#
#             # result_df = result_df.with_column(
#             #     f"PARTITION_VALUES_{run_dttm_str}", F.lit([])
#             # )
#
#             # # **** Using Snowpark ML **** 
#             isolation_forest = sml.IsolationForest(input_cols=ANOMALY_DETECTION_COLUMNS, **parameters_dict)
#
#             isolation_forest.fit(transformed_df)
#
#             scores = isolation_forest.decision_function(transformed_df, output_cols_prefix='DECISION_FUNC_')
#
#             result_df = scores.select(
#                 record_id_cols + ['DECISION_FUNC_']
#             ).with_column(
#                 "ANOMALY_SCORE", 
#                 F.lit(-1) * (F.col("DECISION_FUNC_") - F.lit(0.5))
#             ).drop(
#                 "DECISION_FUNC_"
#             )
#
#             result_df = result_df.with_column(
#                 f"PARTITION_VALUES_{run_dttm_str}", F.lit([])
#             )
#
#         else:
#             # # **** scalar UDTF Version ****
#             # # Obtain input types and output schema
#             # input_dtypes = [field.datatype for field in transformed_df.schema.fields]
#
#             # out_schema_fields_list = transformed_df.select([F.col(col_nm).alias('__OUTPUT__'+col_nm) for col_nm in record_id_cols]).schema.fields + [StructField('ANOMALY_SCORE', FloatType())]
#             # out_schema = StructType(out_schema_fields_list)
#
#             # # Use scaler UDTF to run anomaly detection for each partition separately in parallel
#             # @F.udtf(input_types = input_dtypes,
#             #     output_schema = out_schema,
#             #     name = f"perform_anom_detection_udtf_{run_dttm_str}",
#             #     session=session,
#             #     packages=['snowflake-snowpark-python', 'pandas', 'scikit-learn'],
#             #     replace=True)
#             # class anom_detection:
#             #     def __init__(self):
#             #         self.column_names = input_col_names
#             #         self.data = {col: [] for col in self.column_names}
#
#             #     def process(self, *values):
#             #         for col, value in zip(self.column_names, values):
#             #             self.data[col].append(value)
#
#             #     def end_partition(self):
#             #         df = pd.DataFrame(self.data)
#
#             #         final_df = perform_anomaly_detection(df)
#
#             #         yield from final_df.itertuples(index=False, name=None)
#
#             # # Call the UDTF
#             # _udtf = F.table_function(f"perform_anom_detection_udtf_{run_dttm_str}")
#
#             # sdf_scored = transformed_df.select([f"PARTITION_VALUES_{run_dttm_str}"] + [_udtf(*[F.col(col_nm) for col_nm in input_col_names]).over(partition_by=[f"PARTITION_VALUES_{run_dttm_str}"], order_by=record_id_cols)])
#
#             # # Final Snowpark DataFrame
#             # sdf_final = sdf_scored.select([F.col(col_nm).alias(col_nm[10:]) if col_nm.startswith('__OUTPUT__') else col_nm for col_nm in sdf_scored.columns])
#
#             # **** vectorized UDTF Version of the above. ****
#             # Obtain input types and output schema
#             input_dtypes = [field.datatype for field in transformed_df.schema.fields]
#             vect_udtf_input_dtypes = [T.PandasDataFrameType(input_dtypes)]
#
#             out_renamed_fields_list = transformed_df.select(
#                 [
#                     F.col(col_nm).alias("__OUTPUT__" + col_nm)
#                     for col_nm in record_id_cols
#                 ]
#             ).schema.fields
#
#             vect_udtf_out_dtypes_list = [
#                 field.datatype for field in out_renamed_fields_list
#             ] + [T.FloatType()]
#
#             vect_udtf_out_col_names_list = [
#                 field.name for field in out_renamed_fields_list
#             ] + ["ANOMALY_SCORE"]
#
#             vect_udtf_output_schema = T.PandasDataFrameType(
#                 vect_udtf_out_dtypes_list, vect_udtf_out_col_names_list
#             )
#
#             # Use vectorized UDTF to run anomaly detection for each partition separately in parallel
#             udtf_nm = f"{temp_objects_schema}.perform_anom_detection_{run_dttm_str}_udtf_{random_number}"
#
#             class anom_detection:
#                 def end_partition(self, df):
#                     final_df = perform_anomaly_detection(df)
#                     yield final_df
#
#             session.udtf.register(
#                 anom_detection,
#                 output_schema=vect_udtf_output_schema,
#                 input_types=vect_udtf_input_dtypes,
#                 name=udtf_nm,  # Give a unique name to avoid concurrency issues
#                 stage_location=f"@{temp_objects_schema}.{temp_file_stage}",
#                 is_permanent=True,
#                 packages=["snowflake-snowpark-python", "pandas", "scikit-learn"],
#                 replace=True,
#             )
#
#             # Call the UDTF
#             _udtf = F.table_function(udtf_nm)
#
#             sdf_scored = transformed_df.select(
#                 [f"PARTITION_VALUES_{run_dttm_str}"]
#                 + [
#                     _udtf(*[F.col(col_nm) for col_nm in input_col_names]).over(
#                         partition_by=[f"PARTITION_VALUES_{run_dttm_str}"],
#                         order_by=record_id_cols,
#                     )
#                 ]
#             )
#
#             # Final Snowpark DataFrame
#             # NOTE: We had to add the __OUTPUT__ prefix to the udtf output_schema because UDTFs can't have output column names that are the same as input column names.
#             result_df = sdf_scored.select(
#                 [
#                     (
#                         F.col(col_nm).alias(col_nm[10:])
#                         if col_nm.startswith("__OUTPUT__")
#                         else col_nm
#                     )
#                     for col_nm in sdf_scored.columns
#                 ]
#             )
#
#         # **** FORMAT RESULTS ****
#
#         # Combine all the record IDs into one VARIANT column
#         ID_LIST = [
#             item for colnm in record_id_cols for item in (F.lit(colnm), F.col(colnm))
#         ]
#         result_df = result_df.withColumn(
#             "RECORD_DICT", F.object_construct_keep_null(*ID_LIST)
#         )
#
#         result_df = result_df.select(
#             F.lit(8).alias("CHECK_TYPE_ID"),
#             F.col(f"PARTITION_VALUES_{run_dttm_str}").alias("PARTITION_VALUES"),
#             F.col("RECORD_DICT").alias("RECORD_IDS"),
#             "ANOMALY_SCORE",
#         )
#
#
#         # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#         # INCORPORATE ALERT THRESHOLDS
#         # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#         result_df = (
#             result_df
#             .with_column('ALERT_FLAG', F.when(F.col("ANOMALY_SCORE") > F.lit(alert_threshold_value), 1).otherwise(0) )
#             .with_column("ALERT_STATUS", F.when(F.col("ALERT_FLAG")==1, F.lit("pending review")).otherwise(None) )
#         )
#         # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#
#         # Add results to the unioned_results DF
#         unioned_results = unioned_results.union_all_by_name(result_df)
#
#     # *****************************************************
#     # Write Results
#     # *****************************************************
#
#     # NOTE: Added ALERT_FLAG and ALERT_STATUS to the results tables # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#     sdf_final = (
#         unioned_results.select(
#             F.lit(job_id).alias("JOB_ID"),
#             F.lit(run_dttm).alias("RUN_DATETIME"),
#             "CHECK_TYPE_ID",
#             "PARTITION_VALUES",
#             F.lit(qualified_input_table_nm).alias("CHECK_TBL_NM"),
#             "RECORD_IDS",
#             "ANOMALY_SCORE",
#             "ALERT_FLAG", # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#             "ALERT_STATUS" # *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
#         )
#         .select(
#             results_tbl_columns  # This second .select() ensures the columns are in the correct order to be inserted into an existing table if job_id>=0
#         )
#         .sort("CHECK_TYPE_ID", "PARTITION_VALUES", "ANOMALY_SCORE")
#     )
#
#     # write the results to Snowflake temp table
#     sdf_final.write.save_as_table(qualified_result_tbl_nm, mode="append")
#
#     return {
#         "QUALIFIED_RESULT_TBL_NM": qualified_result_tbl_nm,
#         "RESULT_DB": results_db,
#         "RESULT_SCHEMA": results_schema,
#         "RESULT_TBL_NM": results_tbl_nm,
#         "JOB_NAME": job_nm,
#         "JOB_ID": job_id,
#         "PARTITION_COLUMNS": partition_cols,
#         "UDTF_NM": udtf_nm,
#     }
#
# func = anomaly_detection_sproc

def compute(session,arg1,arg2):
    return func(session,arg1,arg2)