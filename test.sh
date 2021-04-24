docker build -q -t sub .
docker run --rm --name sub -d -p 8080:8080 sub

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":151,"state":{"a":62,"b":1,"c":66,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":151,"state":{"a":0,"b":1,"c":66,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":true,"auxCarry":true,"parity":true,"carry":false},"programCounter":1,"stackPointer":2,"cycles":4}}'

docker kill sub

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSUB Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSUB Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi