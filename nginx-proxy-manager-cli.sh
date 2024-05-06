#!/bin/bash

# Initialize BASE_URL, TOKEN, USERNAME and PASSWORD with default values or empty strings
BASE_URL="http://localhost:81"
TOKEN=""
USERNAME=""
PASSWORD=""

# Function to print usage instructions
usage() {
    echo "Usage: $0 [-u BASE_URL] [-U USERNAME] [-P PASSWORD] COMMAND [OPTIONS]"
    echo
    echo "Options:"
    echo "  -u BASE_URL       Base URL of the Nginx Proxy Manager API" 
    echo "  -U USERNAME       Username for obtaining the token"
    echo "  -P PASSWORD       Password for obtaining the token"
    echo
    echo "Commands:"
    echo "  list-proxies      List all proxy hosts"
    echo "  get-proxy         Get details of a specific proxy host"
    echo "  create-proxy      Create a new proxy host"
    echo "  update-proxy      Update an existing proxy host"
    echo "  delete-proxy      Delete a proxy host"
    echo
    echo "Examples:"
    echo "  $0 -u http://localhost:81 -U admin -P changeme list-proxies"
    echo "  $0 -u http://localhost:81 -U admin -P changeme get-proxy 1"
    echo "  $0 -u http://localhost:81 -U admin -P changeme list-proxies -o table"
    echo "  $0 -u http://localhost:81 -U admin -P changeme update-proxy 1 proxy.json"
    exit 1
}

# Function to get an API token
get_token() {
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/tokens" -H "Content-Type: application/json" -d "{\"identity\": \"$USERNAME\", \"secret\": \"$PASSWORD\"}")
    TOKEN=$(echo "$RESPONSE" | jq -r '.token')
}

# Function to convert JSON to the desired output format
convert_output() {
    local json_data="$1"
    local format="$2"
    local table_structure="$3"

    case "$format" in
        "table")
            headers=$(echo -e "ID\tDomains\tForward Host\tPort\tEnabled\tOnline")
            data=$(echo "$json_data" | jq -r "$table_structure")
            echo -e "$headers\n$data" | column -t -s $'\t'
            ;;
        "yaml")
            echo "$json_data" | yq -P
            ;;
        *)
            echo "$json_data" | jq '.'
            ;;
    esac
}



# Function to list all proxy hosts
list_proxies() {
    local format="$1"
    RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/nginx/proxy-hosts")
    table_jq_structure='.[] | [.id, (.domain_names | join(",")), .forward_host, .forward_port, if .enabled == 1 then "true" else "false" end, .meta.nginx_online] | @tsv'
    echo "$format"
    convert_output "$RESPONSE" "$format" "$table_jq_structure"
}

# Function to get details of a specific proxy host
get_proxy() {
    local id="$1"
    local format="$2"
    RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/nginx/proxy-hosts/$id")
    table_jq_structure='.[0] | [.id, (.domain_names | join(",")), .forward_host, .forward_port, if .enabled == 1 then "true" else "false" end, .meta.nginx_online] | @tsv'
    convert_output "$RESPONSE" "$format" "$table_jq_structure"
}

# Function to create a new proxy host
create_proxy() {
    local json_file="$1"
    echo "Creating a new proxy host..."
    curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "@$json_file" "$BASE_URL/api/nginx/proxy-hosts" | jq '.'
}

# Function to update an existing proxy host
update_proxy() {
    local id="$1"
    local json_file="$2"
    echo "Updating proxy host with ID: $id..."
    curl -s -X PUT -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "@$json_file" "$BASE_URL/api/nginx/proxy-hosts/$id" | jq '.'
}

# Function to delete a proxy host
delete_proxy() {
    local id="$1"
    echo "Deleting proxy host with ID: $id..."
    curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/nginx/proxy-hosts/$id" | jq '.'
}

# Parse command-line options
while getopts ":u:U:P:" opt; do
    case ${opt} in
        u)
            BASE_URL="$OPTARG"
            ;;
        U)
            USERNAME="$OPTARG"
            ;;
        P)
            PASSWORD="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Remove the options that have been parsed by getopts
shift $((OPTIND - 1))

# If USERNAME and PASSWORD are provided, get a new token
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Both USERNAME (-U) and PASSWORD (-P) are required."
    exit 1
fi

get_token

# Main execution starts here
if [ "$#" -eq 0 ]; then
    usage
fi

COMMAND="$1"
shift

FORMAT=""
if [ "$1" == "-o" ]; then
    if [ "$2" == "table" ]; then
        FORMAT="table"
        shift 2
    elif [ "$2" == "yaml" ]; then
        FORMAT="yaml"
        shift 2
    else
        echo "Formato no reconocido: $2"
        exit 1
    fi
fi

case "$COMMAND" in
    "list-proxies")
        list_proxies "$FORMAT"
        ;;
    "get-proxy")
        get_proxy "$1" "$FORMAT"
        ;;
    "create-proxy")
        create_proxy "$@"
        ;;
    "update-proxy")
        update_proxy "$@"
        ;;
    "delete-proxy")
        delete_proxy "$@"
        ;;
    *)
        usage
        ;;
esac
