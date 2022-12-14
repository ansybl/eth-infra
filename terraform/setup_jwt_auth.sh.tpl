# Generates a config file with templated values.
#
# Terraform interpolation uses standard shell interpolation syntax ($).
# So shell interpolation inside a Terraform template must be escaped ($$).
# Command substitution does not need escaping ($).

set -o errexit -o nounset -o pipefail -o posix

mkdir -p "$(dirname "${jwt_hex_path}")"

echo ${jwt_hex} > "${jwt_hex_path}"
