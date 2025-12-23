@Library("shared-libraries") _

import ar.com.nbch.jenkins.flyway.Flyway

def server(String branch){
    if (branch == 'master'){
        return ['TODOS',
        'app',
        'batch',
        'pos',
        'ws',
        'ext'
        ]
    }
    else if (branch == 'integracion'){
        return ['TODOS',
        'integracion']
    }
    else if (branch == 'stage'){
        return ['TODOS',
        'app',
        'batch',
        'pos',
        'ws',
        'ext'
        ]
    }
    else if (branch == 'qa'){
        return ['TODOS',
        'contabilidad',
        'desa01',
        'desa02',
        'delta',
        'eta',
        'iota',
        'mu',
        'mu-pos',
        'operaciones',
        'pasivas',
        'tesoreria'
        ]
    }
    else if (branch == 'beta'){
        return ['TODOS',
        'pre-integracion'
        ]
    }
    else if (branch == 'lambda'){
        return ['TODOS',
        'lambda']
    }
    else if (branch == 'infra'){
        return ['TODOS',
        'infra']
    }
    else if (branch == 'eta'){
        return ['TODOS',
        'eta']
    }
  	else if (branch == 'gamma'){
        return ['TODOS',
        'gamma']
    }
    else if (branch == 'interfaces'){
        return ['TODOS',
        'interfaces',
        'interfaces-pos']
    }
    else if (branch == 'activas'){
        return ['TODOS',
        'activas']
    }
    else if (branch == 'rrii'){
        return ['TODOS',
        'rrii']
    }
    else if (branch == 'depurar-branches'){
        return ['TODOS',
        'depurar-branches']
    }
}


def Reiniciar(boolean PARAM_REINICIAR, String PARAM_COMMANDS){
    if (PARAM_REINICIAR){
        return 'telnet, telnet-reload'
    }
    else if (PARAM_COMMANDS != ''){
        return 'restart-servicio, telnet'
    }
    return 'restart-servicio, telnet, telnet-reload'
}

def PullPackageV2(String servers, boolean PARAM_REINICIAR, boolean PARAM_SOLO_SQL, String quantity, String PARAM_COMMANDS){
    if (!PARAM_SOLO_SQL){
        echo "Reiniciar ${PARAM_REINICIAR}"
        def tags = Reiniciar(PARAM_REINICIAR, PARAM_COMMANDS)
        echo "Omit tags: ${tags}"

        // Comandos
        def command_selected = PARAM_COMMANDS.split(',').collect { it.trim() }
        if (command_selected.contains("RELOAD ALL")) {
            command_selected = "[]"
        }
        command_selected = "${command_selected}"
        echo "${command_selected}"
        
        echo "########## INICIO DEPLOY APP ##########"
        ansibleTower(
            towerServer: 'ansible',
            templateType: 'job',
            jobTemplate: "topaz-app-deploy-v2",
            towerLogLevel: 'full',
            inventory: "topaz-app",
            skipJobTags: tags,
            limit: servers,
            removeColor: false,
          	scmBranch: 'master',
            verbose: true,
            extraVars: """{
                "SERIAL_QUANTITY": ${quantity},
                "commands": ${command_selected}
            }
            """,
            async: false
        )
        echo "########## INICIO DEPLOY APP ##########"
    }
}

def migrar(String use, String pass, String url){
    echo "########## INICIO MIGRAR FLYWAY ##########"
    echo "########## CONECTAR FLYWAY ##########"
    Flyway flyway = new Flyway(this, use, pass, url, "sql/scripts", "com.microsoft.sqlserver.jdbc.SQLServerDriver", "flyway_schema_history_10_13_0", "true", ['dbo'], [remplazoVariables: 'false'])
    echo "########## INFO FLYWAY ##########"
    flyway.info()
    echo "########## MIGRATE FLYWAY ##########"
    flyway.migrate()
    echo "########## INFO FLYWAY ##########"
    flyway.info()
    echo "########## FIN MIGRAR FLYWAY ##########"
}

def f_commands(){
    return [
        "RELOAD ALL",
        "'caches'",
        "'catalog'",
        "'charges'",
        "'defcontrasiento'",
        "'desdetcont'",
        "'ds'",
        "'eventtrcode'",
        "'groups'",
        "'holidays'",
        "'hook'",
        "'instfields'",
        "'jbank'",
        "'metadata'",
        "'netmap'",
        "'numcaja'",
        "'permissions'",
        "'pm'",
        "'schemes'",
        "'services'",
        "'topazempsuc'",
        "'topazmap'",
        "'topazprt'",
        "'trcode'",
        "'wsinterpreted'"
    ]
}

properties([
    parameters([
        booleanParam(
            name: 'REINICIAR',
            defaultValue: false,
            description: 'Tildar la casilla si se debe reiniciar los servicios'
        ),
        extendedChoice(
            name: 'SERVERS',
            multiSelectDelimiter: ',',
            type: 'PT_CHECKBOX',
            description: 'Seleccionar uno o varios servidores',
            defaultValue: 'TODOS',
            value: server(env.BRANCH_NAME).join(','),
            visibleItemCount: 20
        ),
        extendedChoice(
            name: 'COMMANDS',
            multiSelectDelimiter: ',',
            type: 'PT_CHECKBOX',
            description: 'Seleccionar uno o varios comandos',
            defaultValue: '',
            value: f_commands().join(','),
            visibleItemCount: 20
        ),
        booleanParam(
            name: 'SOLO_SQL',
            defaultValue: false,
            description: 'Tildar la casilla si solo se ejecutan los script de SQL'
        ),
    ])
])

pipeline {
    /**
    Environment Variables 
    **/  
    environment {
        /************************
        ** Ambiente Produccion **
        *************************/
        USR_FLYWAY_PRD = credentials('USR_FLYWAY_P')
        URL_PRD = 'jdbc:sqlserver://topaz-db.nbch.com.ar;databaseName=core;encrypt=true;trustServerCertificate=true;'
        URL_PRD_EXT = 'jdbc:sqlserver://topaz-ext-db.nbch.com.ar;databaseName=core_ext;encrypt=true;trustServerCertificate=true;'

        /*********************
        ** Ambiente Testing **
        *********************/
        USR_FLYWAY_T = credentials('USR_FLYWAY_T')
        
        URL_STG_2 = 'jdbc:sqlserver://topaz-stage01-db.nbch.com.ar;databaseName=stage02_core;encrypt=true;trustServerCertificate=true;'
        URL_IOTA = 'jdbc:sqlserver://topaz-iota-db.nbch.com.ar;databaseName=iota;encrypt=true;trustServerCertificate=true;'
        URL_ETA = 'jdbc:sqlserver://topaz-eta-db.nbch.com.ar;databaseName=migracion;encrypt=true;trustServerCertificate=true;'
        URL_EPSILON = 'jdbc:sqlserver://topaz-epsilon-db.nbch.com.ar;databaseName=parametria;encrypt=true;trustServerCertificate=true;'
        URL_ALPHA_BATCH = 'jdbc:sqlserver://topaz-alpha-batch-db.nbch.com.ar;databaseName=alpha-batch;encrypt=true;trustServerCertificate=true;'
      	URL_ACTIVAS = 'jdbc:sqlserver://topaz-activas-db.nbch.com.ar;databaseName=activas;encrypt=true;trustServerCertificate=true;'
        URL_PASIVAS = 'jdbc:sqlserver://topaz-pasivas-db.nbch.com.ar;databaseName=pasivas;encrypt=true;trustServerCertificate=true;'
        URL_CONTABILIDAD = 'jdbc:sqlserver://topaz-contabilidad-db.nbch.com.ar;databaseName=contabilidad;encrypt=true;trustServerCertificate=true;'
        URL_DESA_02 = 'jdbc:sqlserver://topaz-desa02-db.nbch.com.ar;databaseName=desa02_core;encrypt=true;trustServerCertificate=true;'
        URL_INFRA = 'jdbc:sqlserver://topaz-infra-db.nbch.com.ar;databaseName=infra;encrypt=true;trustServerCertificate=true;'
        
        /************************
        ** Ambiente Desarrollo **
        *************************/
        USR_FLYWAY_D = credentials('USR_FLYWAY_D')
        
        URL_DELTA = 'jdbc:sqlserver://topaz-delta-db.nbch.com.ar;databaseName=delta;encrypt=true;trustServerCertificate=true;'
        URL_MU = 'jdbc:sqlserver://topaz-mu-db.nbch.com.ar;databaseName=mu;encrypt=true;trustServerCertificate=true;'
        URL_BETA = 'jdbc:sqlserver://topaz-beta-db.nbch.com.ar;databaseName=beta;encrypt=true;trustServerCertificate=true;'
        URL_LAMBDA = 'jdbc:sqlserver://topaz-lambda-db.nbch.com.ar;databaseName=lambda;encrypt=true;trustServerCertificate=true;'
        URL_OPERACIONES = 'jdbc:sqlserver://topaz-operaciones-db.nbch.com.ar;databaseName=operaciones;encrypt=true;trustServerCertificate=true;'
        URL_INTERFACES = 'jdbc:sqlserver://topaz-interfaces-db.nbch.com.ar;databaseName=interfaces;encrypt=true;trustServerCertificate=true;'
        URL_TESORERIA = 'jdbc:sqlserver://topaz-tesoreria-db.nbch.com.ar;databaseName=tesoreria;encrypt=true;trustServerCertificate=true;'
        URL_GAMMA = 'jdbc:sqlserver://topaz-gamma-db.nbch.com.ar;databaseName=gamma;encrypt=true;trustServerCertificate=true;'
        URL_RRII = 'jdbc:sqlserver://topaz-regimenes-db.nbch.com.ar;databaseName=regimenes;encrypt=true;trustServerCertificate=true;'
        URL_LINK_POS = 'jdbc:sqlserver://topaz-link-dbd.nbch.com.ar;databaseName=link;encrypt=true;trustServerCertificate=true;'
        URL_DESA_01 = 'jdbc:sqlserver://topaz-desa01-db.nbch.com.ar;databaseName=desa01_core;encrypt=true;trustServerCertificate=true;'        
        
        /************
        ** COMMON  **
        ************/
        TEAMS_URL = 'https://nbch.webhook.office.com/webhookb2/da98b55c-2aa1-4010-9492-0f26a60048a6@5b80e1b5-72dc-444f-8a50-64b45a9a40cb/IncomingWebhook/675a261225944b2fa13d75d931394362/e10dd1f3-2e37-45ed-81c2-ccc5cde7c38d/V2wdpAnUPWMOyOhCBiqWmyBRuipUC81qi9EDGkc2dBLjg1'
		FLYWAY_LICENSE = credentials('flyway-license-key')
    }
    

    agent { docker { image 'registry.nbch.com.ar/jnk/flyway:10.13.0' } }
    stages{
        /************************
        ** Ambiente Desarrollo **
        *************************/
        stage('Desarrollo'){
            when {
                branch(pattern: 'infra|interfaces|gamma|lambda', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }
                    
                    // Definimos un Map para parallel
                    def parallelStages = [:]

                    // Agregamos solo los que cumplen la condición
                    if ((env.BRANCH_NAME == "infra") && (sel.contains('TODOS') || sel.contains('infra'))) {
                        parallelStages["infra"] = {
                            echo 'Ejecutando tareas infra'

                            migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_INFRA}")
                            PullPackageV2("topaz-infra-app", params.REINICIAR, params.SOLO_SQL, "3", params.COMMANDS)
                            if (params.REINICIAR){
                                sleep time: 20, unit: 'SECONDS'
                            }
                            else {
                                sleep time: 10, unit: 'SECONDS'
                            }
                        }
                    }
                    if ((env.BRANCH_NAME == "interfaces")){
                        if(sel.contains('TODOS') || sel.contains('interfaces')){
                            parallelStages["interfaces"] = {
                                echo 'Ejecutando tareas interfaces'
                                migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_INTERFACES}")
                                PullPackageV2("topaz-interfaces-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                                if(params.REINICIAR){
                                    sleep time: 60, unit: 'SECONDS'
                                } else {
                                    sleep time: 10, unit: 'SECONDS'
                                }
                                build 'Herramientas Desarrollo/config/topazprocessexec-config/develop'
                            }
                        }

                        if (sel.contains('TODOS') || sel.contains('interfaces-pos')){
                            parallelStages["interfaces-pos"] = {
                                echo 'Ejecutando tareas interfaces-pos'
                                PullPackageV2("topaz-interfaces-pos", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                            } 
                        }
                    }
                    if ((env.BRANCH_NAME == "gamma") && (sel.contains('TODOS') || sel.contains('gamma'))) {
                        parallelStages["gamma"] = {
                            echo 'Ejecutando tareas gamma'
                            migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_GAMMA}")
                            PullPackageV2("topaz-gamma-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        }
                    }
                    if ((env.BRANCH_NAME == "lambda") && (sel.contains('TODOS') || sel.contains('lambda'))) {
                        parallelStages["lambda"] = {
                            echo 'Ejecutando tareas lambda'
                            migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_LAMBDA}")
                            PullPackageV2("topaz-lambda-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        }
                    }

                    echo "Se ejecutara en paralelo ${parallelStages}"
                    parallel parallelStages
                }
            }
        }

        stage('BETA - Pre-Integracion'){
            when {
                branch(pattern: 'beta', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo 'Ejecutando tareas pre-intregacion, viejo BETA'
                    migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_BETA}")
                    PullPackageV2("topaz-beta-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                }
            }
        }

        /************************
        ** Ambiente Testing **
        *************************/
        stage('Testing'){
            when {
                branch(pattern: 'qa', comparator: "REGEXP")
            }
			stages {
				stage('Desa02') {
					steps {
                        script {
                            // Servers
                            def sel = params.SERVERS.split(',').collect { it.trim() }

                            echo "Armando siguientes pasos para ejecucion en paralelo..."
                            def parallelStages = [:]

                            if (sel.contains('TODOS') || sel.contains('desa02')){
                                parallelStages["desa02"] = {
                                    echo 'Ejecutando tareas desa02'
                                    migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_DESA_02}")
                                    PullPackageV2("topaz-desa02-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)		
                                } 
                            }
                            echo "Se ejecutara en paralelo ${parallelStages}"
							parallel parallelStages  
                        }						
                    }
				}
				stage('Testing'){
					steps{
						script {
							// Servers
							def sel = params.SERVERS.split(',').collect { it.trim() }

							echo "Armando siguientes pasos para ejecucion en paralelo..."
							def parallelStages = [:]

							if (sel.contains('TODOS') || sel.contains('contabilidad')){
								parallelStages["contabilidad"] = {
									echo 'Ejecutando tareas contabilidad'
									migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_CONTABILIDAD}")
									PullPackageV2("topaz-contabilidad-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('delta')){
								parallelStages["delta"] = {
									echo 'Ejecutando tareas delta'
									migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_DELTA}")
									PullPackageV2("topaz-delta-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('eta')){
								parallelStages["eta"] = {
									echo 'Ejecutando tareas eta'
									migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_ETA}")
									PullPackageV2("topaz-eta-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('desa01')){
								parallelStages["desa01"] = {
									echo 'Ejecutando tareas desa01'
									migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_DESA_01}")
									PullPackageV2("topaz-desa01-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('iota')){
								parallelStages["iota"] = {
									echo 'Ejecutando tareas iota'
									migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_IOTA}")
									PullPackageV2("topaz-iota-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
									sleep time: 30, unit: 'SECONDS'
									build 'Herramientas Desarrollo/config/topazprocessexec-config/qa'
								} 
							}
							if (sel.contains('TODOS') || sel.contains('mu')){
								parallelStages["mu"] = {
									echo 'Ejecutando tareas mu'
									migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_MU}")
									PullPackageV2("topaz-mu-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('mu-pos')){
								parallelStages["mu-pos"] = {
									echo 'Ejecutando tareas mu-pos'
									PullPackageV2("topaz-link-pos", params.REINICIAR, params.SOLO_SQL, "2", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('operaciones')){
								parallelStages["operaciones"] = {
									echo 'Ejecutando tareas operaciones'
									migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_OPERACIONES}")
									PullPackageV2("topaz-operaciones-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('pasivas')){
								parallelStages["pasivas"] = {
									echo 'Ejecutando tareas pasivas'
									migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_PASIVAS}")
									PullPackageV2("topaz-pasivas-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}
							if (sel.contains('TODOS') || sel.contains('tesoreria')){
								parallelStages["tesoreria"] = {
									echo 'Ejecutando tareas tesoreria'
									migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_TESORERIA}")
									PullPackageV2("topaz-tesoreria-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
								} 
							}

							echo "Se ejecutara en paralelo ${parallelStages}"
							parallel parallelStages
						}
					}
				}
			}	
        }
        /************************
        ** Ambiente Activas **
        *************************/
        stage('Activas'){
            when {
                branch(pattern: 'activas', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo "Armando siguientes pasos para ejecucion en paralelo..."
                    def parallelStages = [:]
                    
                    if (sel.contains('TODOS') || sel.contains('activas')){
                        parallelStages["activas"] = {
                            echo 'Ejecutando tareas activas'
                            migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_ACTIVAS}")
                            PullPackageV2("topaz-activas-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        }   
                    }

                    echo "Se ejecutara en paralelo ${parallelStages}"
                    parallel parallelStages
                }
            }
        }
        /************************
        ** Ambiente RRII **
        *************************/
        stage('RRII'){
            when {
                branch(pattern: 'rrii', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo "Armando siguientes pasos para ejecucion en paralelo..."
                    def parallelStages = [:]
                    
                    if (sel.contains('TODOS') || sel.contains('rrii')){
                        parallelStages["rrii"] = {
                            echo 'Ejecutando tareas rrii'
                            migrar("${USR_FLYWAY_D_USR}", "${USR_FLYWAY_D_PSW}", "${URL_RRII}")
                            PullPackageV2("topaz-rrii-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        }   
                    }

                    echo "Se ejecutara en paralelo ${parallelStages}"
                    parallel parallelStages
                }
            }
        }        
        /************************
        ** Ambiente Stage **
        *************************/
        stage('Stage'){
            when {
                branch(pattern: 'stage', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo "Armando siguientes pasos para ejecucion en paralelo..."
                    def parallelStages = [:]
                    
                    migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_STG_2}")

                    if (sel.contains('TODOS') || sel.contains('app')){
                        parallelStages["app"] = {
                            echo 'Ejecutando tareas stage app'
                            PullPackageV2("topaz-stage01-app", params.REINICIAR, params.SOLO_SQL, "2", params.COMMANDS)
                        }   
                    }
                    if (sel.contains('TODOS') || sel.contains('batch')){
                        parallelStages["batch"] = {
                            echo 'Ejecutando tareas stage batch'
                            PullPackageV2("topaz-stage01-bat", params.REINICIAR, params.SOLO_SQL, "2", params.COMMANDS)
                        } 
                    }
                    if (sel.contains('TODOS') || sel.contains('pos')){
                        parallelStages["pos"] = {
                            echo 'Ejecutando tareas stage pos'
                            PullPackageV2("topaz-stage01-pos", params.REINICIAR, params.SOLO_SQL, "4", params.COMMANDS)
                        } 
                    }
                    if (sel.contains('TODOS') || sel.contains('ws')){
                        parallelStages["ws"] = {
                            echo 'Ejecutando tareas stage ws'
                            PullPackageV2("topaz-stage01-ws", params.REINICIAR, params.SOLO_SQL, "2", params.COMMANDS)
                        } 
                    }

                    echo "Se ejecutara en paralelo ${parallelStages}"
                    parallel parallelStages
                }
            }
        }

        /*************************
        ** Ambiente Integracion **
        **************************/
        stage('Integracion'){
            when {
                branch(pattern: 'integracion', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo 'Ejecutando tareas integracion, viejo ALPHA-BATCH'
                    migrar("${USR_FLYWAY_T_USR}", "${USR_FLYWAY_T_PSW}", "${URL_ALPHA_BATCH}")
                    PullPackageV2("topaz-alpha-batch", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                }
            }
        }

        /************************
        ** Ambiente Produccion **
        *************************/
        stage('Produccion'){
            when {
                branch(pattern: 'master', comparator: "REGEXP")
            }
            steps{
                script {
                    // Servers
                    def sel = params.SERVERS.split(',').collect { it.trim() }

                    echo "Armando siguientes pasos para ejecucion en paralelo..."
                    def parallelStages = [:]

                    migrar("${USR_FLYWAY_PRD_USR}", "${USR_FLYWAY_PRD_PSW}", "${URL_PRD}")

                    if (sel.contains('TODOS') || sel.contains('app')){
                        parallelStages["app"] = {
                            echo 'Ejecutando tareas prod app'
                            PullPackageV2("topaz-prod01-app", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        }   
                    }
                    if (sel.contains('TODOS') || sel.contains('batch')){
                        parallelStages["batch"] = {
                            echo 'Ejecutando tareas prod batch'
                            PullPackageV2("topaz-prod01-bat", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                            if(params.REINICIAR){
                                sleep time: 60, unit: 'SECONDS'
                            } else {
                                sleep time: 10, unit: 'SECONDS'
                            }
                            build 'Herramientas Desarrollo/config/topazprocessexec-config/master'
                        } 
                    }
                    if (sel.contains('TODOS') || sel.contains('pos')){
                        parallelStages["pos"] = {
                            echo 'Ejecutando tareas prod pos'
                            PullPackageV2("topaz-prod01-pos", params.REINICIAR, params.SOLO_SQL, "2", params.COMMANDS)
                        } 
                    }
                    if (sel.contains('TODOS') || sel.contains('ws')){
                        parallelStages["ws"] = {
                            echo 'Ejecutando tareas prod ws'
                            PullPackageV2("topaz-prod01-ws", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        } 
                    }
                    if (sel.contains('TODOS') || sel.contains('ext')){
                        parallelStages["ext"] = {
                            echo 'Ejecutando tareas prod ext'
                            migrar("${USR_FLYWAY_PRD_USR}", "${USR_FLYWAY_PRD_PSW}", "${URL_PRD_EXT}")
                            PullPackageV2("topaz-prod01-ext", params.REINICIAR, params.SOLO_SQL, "1", params.COMMANDS)
                        } 
                    }

                    echo "Se ejecutara en paralelo ${parallelStages}"
                    parallel parallelStages
                }
            }
        }

        stage('Eliminar ramas release y feature mergeadas a master') {
            when {
                branch 'depurar-branches'  // o master si preferís hacerlo luego del deploy
            }
            steps {
                script {
                    withCredentials([GitUsernamePassword(credentialsId: 'usr_jenkins', gitToolName: 'Default')]) {
                        sh 'git fetch --unshallow || true'
                        sh 'git fetch origin +refs/heads/*:refs/remotes/origin/*'

                        def mergedBranches = sh(
                            script: "git branch -r --merged origin/master | grep 'origin/' || true",
                            returnStdout: true
                        ).trim().split('\n')

                        // Contadores
                        def countReleases = 0
                        def countDirectFeatures = 0
                        def countRelatedFeatures = 0

                        mergedBranches.each { fullBranch ->
                            fullBranch = fullBranch.trim()

                            if (fullBranch.startsWith('origin/release/')) {
                                def releaseBranch = fullBranch.replace('origin/', '')
                                def featureBranch = releaseBranch.replace('release/', 'feature/')

                                echo "🗑 Eliminando release: ${releaseBranch}"
                                sh "git push origin --delete ${releaseBranch}"
                                countReleases++

                                def exists = sh(
                                    script: "git ls-remote --exit-code --heads origin ${featureBranch} > /dev/null 2>&1 && echo 'yes' || echo 'no'",
                                    returnStdout: true
                                ).trim()

                                if (exists == 'yes') {
                                    echo "🗑 Eliminando feature relacionada: ${featureBranch}"
                                    sh "git push origin --delete ${featureBranch}"
                                    countRelatedFeatures++
                                } else {
                                    echo "🔸 Feature relacionada no encontrada: ${featureBranch}"
                                }
                            }
                            else if (fullBranch.startsWith('origin/feature/')) {
                                def featureBranch = fullBranch.replace('origin/', '')
                                echo "🗑 Eliminando feature mergeada: ${featureBranch}"
                                sh "git push origin --delete ${featureBranch}"
                                countDirectFeatures++
                            }
                        }

                        def totalEliminadas = countReleases + countRelatedFeatures + countDirectFeatures
                        echo "🧹 Resumen de ramas eliminadas:"
                        echo "   🔴 Releases eliminadas: ${countReleases}"
                        echo "   🟠 Features desde release eliminadas: ${countRelatedFeatures}"
                        echo "   🟢 Features directas eliminadas: ${countDirectFeatures}"
                        echo "   ✅ Total de ramas eliminadas: ${totalEliminadas}"
                    }
                }
            }
        }        
    }
    
    post { 
        /* Always delete dir */
        always {
            deleteDir()
        }
        success {
            script {
                def message = "🟩 El trabajo [**$JOB_NAME**](${BUILD_URL}) número **${BUILD_NUMBER}** fue un éxito 🍻."
                teams(TEAMS_URL, message)
            }
        }

        unstable {
            script {
                def message = "🟨 El trabajo [**$JOB_NAME**](${BUILD_URL}) número **${BUILD_NUMBER}** fue inestable 💣."
                teams(TEAMS_URL, message)
            }
        }

        failure {           
            script{
                def message = "🟥 El trabajo [**$JOB_NAME**](${BUILD_URL}) número **${BUILD_NUMBER}** falló 💥."
                teams(TEAMS_URL, message)
            }
        }
    }
}
