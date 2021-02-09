& terraform.exe apply -auto-approve;
az appconfig kv set -n socratic-config --key ServiceBus:Topic --value socratic-topic -y;
az appconfig kv set -n socratic-config --key ServiceBus:Subscription --value socratic-sub -y;
func azure functionapp publish socraticdevfuncapp --dotnet --script-root ..\src\funcApp\;