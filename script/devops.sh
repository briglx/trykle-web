#!/usr/bin/env bash
#########################################################################
# Onboard and manage application on cloud infrastructure.
# Usage: devops.sh [COMMAND]
# Globals:
#
# Commands
#   provision  Provision resources.
#   deploy          Prepare the app and deploy to cloud.
# Params
#    -h, --help     Show this message and get help for a command.
#    -l, --location Resource location. Default westus3
#########################################################################

# Stop on errors
set -e

show_help() {
    echo "$0 : Onboard and manage application on cloud infrastructure." >&2
    echo "Usage: devops.sh [COMMAND]"
    echo "Globals"
    echo
    echo "Commands"
    echo "  provision       Provision resources."
    echo "  deploy          Prepare the app and deploy to cloud."
    echo "Params"
    echo "   -h, --help     Show this message and get help for a command."
    echo "   -l, --location Resource location. Default westus3"
    echo
}

validate_parameters(){
    # Check command
    if [ -z "$1" ]
    then
        echo "COMMAND is required (provision | deploy)" >&2
        show_help
        exit 1
    fi
}

validate_deployment(){
    pass
}
provision(){
    # Provision resources for the application.
    local location=$1
    local deployment_name="Trykle.Provisioning-${run_date}"

    additional_parameters=("message=$message")
    if [ -n "$location" ]
    then
        additional_parameters+=("location=$location")
    fi

    echo "Deploying ${deployment_name} with ${additional_parameters[*]}"

    # shellcheck source=/home/brlamore/src/trykle-web/iac/app.sh
    source "${INFRA_DIRECTORY}/connectivity.sh" --parameters "${additional_parameters[@]}"
}

provision_common(){
    # Provision resources for the application.
    local location=$1
    local deployment_name="common_services.Provisioning-${run_date}"

    additional_parameters=("message=$message")
    if [ -n "$location" ]
    then
        additional_parameters+=("location=$location")
    fi

    echo "Deploying ${deployment_name} with ${additional_parameters[*]}"

    # shellcheck source=/home/brlamore/src/azure_subscription_boilerplate/iac/common_services_deployment.sh
    source "${INFRA_DIRECTORY}/common_services_deployment.sh" --parameters "${additional_parameters[@]}"
}

delete(){
    echo pass
}

deploy(){
    local source_folder="${PROJ_ROOT_PATH}/functions"
    local destination_dir="${PROJ_ROOT_PATH}/dist"
    local timestamp
    timestamp=$(date +'%Y%m%d%H%M%S')
    local zip_file_name="${app_name}_${timestamp}.zip"
    local zip_file_path="${destination_dir}/${zip_file_name}"

    echo "$0 : deploy $app_name" >&2

    # Ensure the source folder exists
    if [ ! -d "$source_folder" ]; then
        echo "Error: Source folder '$source_folder' does not exist."
        return 1
    fi

    # Create the destination directory if it doesn't exist
    mkdir -p "$(dirname "$zip_file_path")"

    # Create an array for exclusion patterns to zip based on .gitignore
    exclude_patterns=()
    while IFS= read -r pattern; do
        # Skip lines starting with '#' (comments)
        if [[ "$pattern" =~ ^[^#] ]]; then
            exclude_patterns+=("-x./$pattern")
        fi
    done < "${PROJ_ROOT_PATH}/.gitignore"
    exclude_patterns+=("-x./local.settings.*")
    exclude_patterns+=("-x./requirements_dev.txt")

    # Zip the folder to the specified location
    cd "$source_folder"
    zip -r "$zip_file_path" ./* "${exclude_patterns[@]}"

    func azure functionapp publish "$app_name"

    # az functionapp deployment source config-zip \
    #     --name "${functionapp_name}" \
    #     --resource-group "${resource_group}" \
    #     --src "${zip_file_path}"

    # Update environment variables to function app
    update_environment_variables

    echo "Cleaning up"
    rm "${zip_file_path}"

    echo "Done"
}

update_environment_variables(){
    echo pass
}

# Globals
PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
echo "Project root: $PROJ_ROOT_PATH"
SCRIPT_DIRECTORY="${PROJ_ROOT_PATH}/script"
INFRA_DIRECTORY="${PROJ_ROOT_PATH}/iac"

# shellcheck source=common.sh
source "${SCRIPT_DIRECTORY}/common.sh"

# Argument/Options
LONGOPTS=message:,resource-group:,location:,jumpbox,help
OPTIONS=m:g:l:jh

# Variables
message=""
location="westus3"
jumpbox="false"
run_date=$(date +%Y%m%dT%H%M%S)
# ISO_DATE_UTC=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Parse arguments
TEMP=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$TEMP"
unset TEMP
while true; do
    case "$1" in
        -h|--help)
            show_help
            exit
            ;;
        -m|--message)
            message="$2"
            shift 2
            ;;
        -l|--location)
            location="$2"
            shift 2
            ;;
        -j|--jumpbox)
            jumpbox="true"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown parameters."
            show_help
            exit 1
            ;;
    esac
done

validate_parameters "$@"
command=$1
case "$command" in
    create_sp)
        create_sp
        exit 0
        ;;
    provision)
        provision "$location"
        exit 0
        ;;
    delete)
        delete
        exit 0
        ;;
    deploy)
        deploy
        exit 0
        ;;
    update_env)
        update_environment_variables
        exit 0
        ;;
    *)
        echo "Unknown command."
        show_help
        exit 1
        ;;
esac
