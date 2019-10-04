
function printHelp() {
  echo "Usage: "
  echo "	./network.sh up"
  echo "	./network.sh down"
  echo "	./network.sh create"
  echo "	./network.sh showkey"  
  echo "	./network.sh start"  
}

function networkUp() {
    keosd &

    nodeos -e -p eosio \
    --plugin eosio::producer_plugin \
    --plugin eosio::chain_api_plugin \
    --plugin eosio::http_plugin \
    --plugin eosio::history_plugin \
    --plugin eosio::history_api_plugin \
    --access-control-allow-origin='*' \
    --contracts-console \
    --http-validate-host=false \
    --verbose-http-errors >> nodeos.log 2>&1 &

    cleos wallet create -n eosiomain -f eosiomain_wallet_password.txt
    cleos wallet import -n eosiomain --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

    cleos wallet create -n cardgamewal -f cardgame_wallet_password.txt
    cleos wallet import -n cardgamewal --private-key 5JpWT4ehouB2FF9aCfdfnZ5AwbQbTtHBAwebRXt94FmjyhXwL4K
    cleos wallet import -n cardgamewal --private-key 5JD9AGTuTeD5BXZwGQ5AtwBqHK21aHmYnTetHgk1B3pjj7krT8N

    cleos wallet import -n cardgamewal --private-key 5KFyaxQW8L6uXFB6wSgC44EsAbzC7ideyhhQ68tiYfdKQp69xKo
}

function createContract() {
    cleos create account eosio cardgameacc EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9

    mkdir -p ./compiled_contracts
    mkdir -p ./compiled_contracts/cardgame

    eosio-cpp --abigen contracts/cardgame/cardgame.cpp -o compiled_contracts/cardgame/cardgame.wasm --contract cardgame

    cleos set contract cardgameacc compiled_contracts/cardgame/ --permission cardgameacc

    cleos create account eosio sarath EOS8Du668rSVDE3KkmhwKkmAyxdBd73B51FKE7SjkKe5YERBULMrw EOS8Du668rSVDE3KkmhwKkmAyxdBd73B51FKE7SjkKe5YERBULMrw
}

function networkDown() {
    pkill keosd
    pkill nodeos
    rm -r ~/eosio-wallet/*
    rm -r ~/.local/share/eosio/nodeos/*
    rm nodeos.log
    rm *.txt
}

function showKey() {
    echo "Account Name: sarath"
    echo "Private Key: 5KFyaxQW8L6uXFB6wSgC44EsAbzC7ideyhhQ68tiYfdKQp69xKo"
}

function startFrontend() {
    cd frontend
    npm start
}

MODE=$1
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then
  networkDown
elif [ "${MODE}" == "create" ]; then
  createContract
elif [ "${MODE}" == "showkey" ]; then
  showKey
elif [ "${MODE}" == "start" ]; then
  startFrontend
else
  printHelp
  exit 1
fi