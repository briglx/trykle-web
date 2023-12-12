#!/usr/bin/env bash
#########################################################################
# Onboard and manage application on cloud infrastructure.
# Usage: devops.sh [COMMAND]
# Globals:
#   ENV_FILE        Path to the environment variables file.
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

replace_parameters(){

    # echo "Replace parameters with environment variables"
    additional_parameters=()
    if [ -n "$location" ]
    then
        additional_parameters+=("location=$location")
    fi
    if [ -n "$APPLICATION_INSIGHTS_NAME" ]
    then
        additional_parameters+=("applicationInsightsName=$APPLICATION_INSIGHTS_NAME")
        additional_parameters+=("applicationInsightsResourceGroup=$APPLICATION_INSIGHTS_RG")
    fi
    if [ -n "$KEY_VAULT_NAME" ]
    then
        additional_parameters+=("keyVaultName=$KEY_VAULT_NAME")
        additional_parameters+=("keyVaultResourceGroup=$KEY_VAULT_RG")
    fi

    echo "${additional_parameters[@]}"

}
validate_deployment(){
    local location=$1
    local deployment_name="Trykle.Provisioning-${run_date}"

    IFS=' ' read -ra additional_parameters <<< "$(replace_parameters)"
    # additional_parameters=($(replace_parameters))

    echo "Validating ${deployment_name} with ${additional_parameters[*]}"

    # shellcheck source=/workspaces/trykle-web/iac/main.sh
    # source "${INFRA_DIRECTORY}/main.sh" --parameters "${additional_parameters[@]}"

    result=$(az deployment sub validate \
        --name "${deployment_name}" \
        --location "$location" \
        --template-file "${INFRA_DIRECTORY}/main.bicep" \
        --parameters "${INFRA_DIRECTORY}/main.parameters.json" \
        --parameters "${additional_parameters[@]}")

    state=$(echo "$result" | jq -r '.properties.provisioningState')
    if [ "$state" != "Succeeded" ]
    then
        echo "Validation failed with state $state"
        echo "$result" | jq -r '.properties.error.details[]'
        exit 1
    fi

}
provision(){
    # Provision resources for the application.
    local location=$1
    local deployment_name="Trykle.Provisioning-${run_date}"

    IFS=' ' read -ra additional_parameters <<< "$(replace_parameters)"

    echo "Deploying ${deployment_name} with ${additional_parameters[*]}"

    # shellcheck source=/workspaces/trykle-web/iac/main.sh
    # source "${INFRA_DIRECTORY}/main.sh" --parameters "${additional_parameters[@]}"

    result=$(az deployment sub create \
        --name "${deployment_name}" \
        --location "$location" \
        --template-file "${INFRA_DIRECTORY}/main.bicep" \
        --parameters "${INFRA_DIRECTORY}/main.parameters.json" \
        --parameters "${additional_parameters[@]}")

    echo "$result" >> "${PROJ_ROOT_PATH}/.azuredeploy.log"

    state=$(echo "$result" | jq -r '.properties.provisioningState')
    if [ "$state" != "Succeeded" ]
    then
        echo "Deployment failed with state $state"
        echo "$result" | jq -r '.properties.error.details[]'
        exit 1
    fi

    # Get the output variables from the deployment
    output_variables=$(az deployment sub show -n "${deployment_name}" --query 'properties.outputs' --output json)
    echo "Save deployment $deployment_name output variables to ${ENV_FILE}"
    {
        echo ""
        echo "# Deployment output variables"
        echo "# Generated on ${ISO_DATE_UTC}"
        echo "$output_variables" | jq -r 'to_entries[] | "\(.key | ascii_upcase )=\(.value.value)"'
    }>> "$ENV_FILE"
}

delete(){
    echo pass
}

deploy(){

    temp_build_dir="./.deploy"
    archive_name="web_app_archive-${run_date}"

    if [[ -z "$WEB_APP_NAME" ]]; then
        echo 'WEB_APP_NAME is required' >&2
        show_help
        exit 2
    fi

    if [[ -z "$WEB_APP_RESOURCE_GROUP_NAME" ]]; then
        echo 'WEB_APP_RESOURCE_GROUP_NAME is required' >&2
        show_help
        exit 2
    fi

    # Remove previous archive
    echo "Remove previous zip if exists."
    if  ls ./*.zip 1> /dev/null 2>&1; then
        echo "Deleting existing .zip files."
        rm ./*.zip
    fi

    echo "Check if dir exists ${temp_build_dir}"
    if [ ! -d "$temp_build_dir" ]; then
        echo "Error: Directory does not exist. $temp_build_dir"
        mkdir "$temp_build_dir"
    else
        echo "Deleting existing ./${temp_build_dir}"
        rm -rf ./"${temp_build_dir:?}"
        mkdir "$temp_build_dir"
    fi

    # copy files to deploy dir
    echo "Copying files to deploy dir"
    cp -r ./static "${temp_build_dir}"
    cp -r ./templates "${temp_build_dir}"
    cp -r ./app.py "${temp_build_dir}"
    cp -r ./requirements.txt "${temp_build_dir}"

    # Change to the target directory
    cd "${temp_build_dir}" || exit 1

    echo "Creating zip"

    py_exclude=('*.pyc' '*__pycache__*')
    flask_exclude=('*flask_session*')
    # zip -r "$archive_name" . -x "${dir_exclude[@]}" "${files_exclude[@]}" "${py_exclude[@]}" "${py_exclude[@]}" "${flask_exclude[@]}"
    zip -r "$archive_name" . -x "${py_exclude[@]}" "${py_exclude[@]}" "${flask_exclude[@]}"

    echo Initiate deployment
    az webapp deploy --name "${WEB_APP_NAME}" --resource-group "$WEB_APP_RESOURCE_GROUP_NAME" --type zip --src-path "${archive_name}.zip"

}

update_environment_variables(){
    echo pass
}

# Globals
PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
echo "Project root: $PROJ_ROOT_PATH"
ENV_FILE="${PROJ_ROOT_PATH}/.env"
SCRIPT_DIRECTORY="${PROJ_ROOT_PATH}/script"
INFRA_DIRECTORY="${PROJ_ROOT_PATH}/iac"

# shellcheck source=/workspaces/trykle-web/script/common.sh
# shellcheck source=/home/runner/work/trykle-web/trykle-web/script/common.sh
source "${SCRIPT_DIRECTORY}/common.sh"

# Argument/Options
LONGOPTS=message:,resource-group:,location:,jumpbox,help
OPTIONS=m:g:l:jh

# Variables
location="westus3"
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
        -l|--location)
            location="$2"
            shift 2
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
        validate_deployment "$location"
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
