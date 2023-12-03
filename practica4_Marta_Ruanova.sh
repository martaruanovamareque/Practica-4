#!/bin/bash
# Para saber o usuario facemos un id -nu e o resultado gardamolo na variable usuario
usuario_ejecutor=$( id -nu )
# Facemos un if para comprobar que o usuario que o executa é root e que indique que
# se non é el que mostre unha mensaxe e finalice o script
if [[ $usuario_ejecutor == "root" ]] ;
then
    # Facemos un bucle para gardar os datos nos array
    while IFS=":" read packagename action;
    do
        paquete[${indice}]=$packagename
        accion[${indice}]=$action
        (( indice ++ ))
    done < paquetes.txt
    # Gardamos o total de voltas do while na variable tamanho
    tamanho=$indice
    # Igualamos indice a 0
    indice=0
    # Realizamos outro while para recorrer os arrays e en base á posición destos engadir, eliminar ou ver o status dos paquetes. Indice ten que ser siempre menor porque no anterior 
    # while sumouselle un valor a maiores.
    while [ $indice -lt $tamanho ] ;
    do
        # Creamos unha variable na que gardemos o resultado do comando para saber se o paquete esta instalado ou non
        buscar_paquete_actual=$( whereis ${paquete[$indice]} | grep bin | wc -l )
        # Facemos un case para que segundo a accion que teña instale, elimine ou de o status
        case ${accion[$indice]} in
            # No caso de ser a accion add ou a realiza as seguintes opcións
            "add" | "a")
                # Controlamos cun if se o paquete está instalado ou no. Se a variable é igual a 0 non está instalado e polo tanto instalamos o paquete
                if [[ $buscar_paquete_actual -eq 0 ]] ;
                then
                    echo "O paquete ${paquete[$indice]} vaise a instalar"
                    # Se o paquete que se quere instalar é chrome primeiro realizanse estas accións
                    if [[ ${paquete[$indice]} == "google-chrome" ]] ;
                    then
                        wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                        apt-get update
                        apt-get -y install libappindicator1
                        dpkg -i google-chrome-stable_current_amd64.deb
                    # Se o paquete que se quere instalar é brave instalamolo a través do snap
                    elif [[ ${paquete[$indice]} == "brave" ]] ;
                    then
                        snap install ${paquete[$indice]}
                    # Se o paquete é o atom instalamos a versión máis recente que é atom4
                    elif [[ ${paquete[$indice]} == "atom" ]] ;
                    then
                        apt install -y atom4
                    # E o resto de paquetes instalamolos pola via normal co apt
                    else
                        apt install -y ${paquete[$indice]}
                    fi
                # Se o valor é maior que 0 entón o paquete está instalado e salta o aviso
                else
                    echo "O paquete ${paquete[$indice]} xa está instalado"
                fi
            ;;
            # No caso de ser a accion remove ou r realiza as seguintes opcións
            "remove" | "r")
                # Controlamos cun if para ver se o paquete está instalado. Se non está instalado salta un anuncio de que non se pode borrar porque non foi instalado con anterioridade
                if [[ $buscar_paquete_actual -eq 0 ]] ;
                then
                    echo "O paquete ${paquete[$indice]} non se pode desinstalar porque non está instalado"
                # Se o paquete está instalado eliminase
                else
                    echo "O paquete ${paquete[$indice]} vaise a desinstalar"
                    apt remove -y ${paquete[$indice]}
                    apt purge -y ${paquete[$indice]}
                fi
                
            ;;
            # No caso de ser a accion status ou s realiza as seguintes opcións
            "status" | "s")
                # Se o paquete non esta instalado sale o aviso de que non pode sacarlle o status
                if [[ $buscar_paquete_actual -eq 0 ]] ;
                then
                    echo "O paquete ${paquete[$indice]} non está instalado polo que non podemos saber o seu status"
                # Se o paquete esta instalado sacamoslle o status
                else
                    echo "El paquete ${paquete[$indice]} se va a ver el status"
                    # Se o paquete é python miramos o estado do sistema de modulos
                    if [[ ${paquete[$indice]} == "python3.8" ]] ;
                    then
                        python3 -m site
                    #Para o resto facemos un systemctl status
                    else
                        systemctl status ${paquete[$indice]}
                    fi
                fi
            ;;
        esac
        (( indice ++))
    done
else
    # Se o usuario non é root sae o aviso e finaliza o script
    echo "El usuario $usuario_ejecutor no tiene permisos para ejecutar el script"
    exit 0
fi