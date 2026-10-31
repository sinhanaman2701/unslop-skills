#!/usr/bin/env bash
# slop-grep.sh - candidate finder for UI slop in Flutter, React Native and web code.
#
# Candidates, never verdicts: every hit must be confirmed by reading file:line.
# Usage:
#   bash slop-grep.sh [--stack flutter|rn|web|auto] [path ...]   scan files or dirs (default: lib for flutter, src otherwise)
#   bash slop-grep.sh --ids [--stack S] [dir]               print "RULE COUNT" lines only
#   bash slop-grep.sh --self-test                           run every stack against scripts/fixtures and assert
# Env: MAX=5 sets how many example hits print per rule.
#
# Rule ids are shared where the idea is shared (S01 emoji, S02 purple palette, S03 gradients, ...). Names differ per
# stack because the same defect has a different shape (a Material FAB, an Android ripple, a div with a click handler).
# Needs: bash, grep -E, perl (all present on macOS).

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAX="${MAX:-5}"
MODE="report"
STACK="auto"

while [ $# -gt 0 ]; do
  case "$1" in
    --self-test) MODE="selftest"; shift ;;
    --ids) MODE="ids"; shift ;;
    --stack) STACK="${2:-auto}"; shift 2 ;;
    --stack=*) STACK="${1#--stack=}"; shift ;;
    *) break ;;
  esac
done

Q="'"   # single quote, for building regexes without \x27 (grep -E has no \x escapes)

# ---------- self test: run each stack against its fixtures ----------
if [ "$MODE" = "selftest" ]; then
  fail=0
  for st in flutter rn web; do
    fx="$HERE/fixtures/$st"
    [ -d "$fx" ] || { echo "FAIL  missing fixtures for $st"; fail=1; continue; }
    ids="$(bash "$0" --ids --stack "$st" "$fx/slop" 2>&1)"
    while read -r id; do
      [ -z "$id" ] && continue
      n=$(printf '%s\n' "$ids" | awk -v id="$id" '$1==id {print $2}')
      if [ "${n:-0}" -lt 1 ]; then echo "FAIL  [$st] $id expected a hit in fixtures/$st/slop, got ${n:-0}"; fail=1; fi
    done < "$fx/expected.txt"
    clean_total=$(bash "$0" --ids --stack "$st" "$fx/clean" | awk '{s+=$2} END {print s+0}')
    if [ "$clean_total" -ne 0 ]; then
      echo "FAIL  [$st] clean fixtures produced $clean_total hits (false positives):"
      bash "$0" --stack "$st" "$fx/clean"; fail=1
    fi
    tok_total=$(bash "$0" --ids --stack "$st" "$fx/token_files" | awk '{s+=$2} END {print s+0}')
    if [ "$tok_total" -ne 0 ]; then
      echo "FAIL  [$st] token-file fixtures produced $tok_total hits (a token or motion file defines the values the rules ban elsewhere):"
      bash "$0" --stack "$st" "$fx/token_files"; fail=1
    fi
  done
  [ "$fail" -eq 0 ] && echo "self-test passed (flutter, rn, web)"
  exit "$fail"
fi

# ---------- target and stack ----------
TARGET_ARG="${1:-}"
TARGETS=("$@")   # one or more files or directories

detect_stack() { # dir-or-file
  local d="$1"; [ -f "$d" ] && d="$(dirname "$d")"
  d="$(cd "$d" 2>/dev/null && pwd)" || { echo web; return; }
  local probe="$d"
  while [ "$probe" != "/" ] && [ -n "$probe" ]; do
    if [ -f "$probe/pubspec.yaml" ]; then echo flutter; return; fi
    if [ -f "$probe/package.json" ]; then
      if grep -qE '"(react-native|expo)"' "$probe/package.json" 2>/dev/null; then echo rn; return; fi
      echo web; return
    fi
    probe="$(dirname "$probe")"
  done
  if find "$d" -type f -name '*.dart' -print -quit 2>/dev/null | grep -q .; then echo flutter; return; fi
  echo web
}

if [ "$STACK" = "auto" ]; then
  if [ -n "$TARGET_ARG" ] && [ -e "$TARGET_ARG" ]; then STACK="$(detect_stack "$TARGET_ARG")"
  elif [ -d lib ] && [ -f pubspec.yaml ]; then STACK=flutter
  else STACK="$(detect_stack .)"; fi
fi
case "$STACK" in flutter|rn|web) ;; *) echo "slop-grep: unknown stack: $STACK (flutter, rn, web)" >&2; exit 2 ;; esac

if [ -n "$TARGET_ARG" ]; then TARGET="${TARGETS[*]}"
elif [ "$STACK" = "flutter" ]; then TARGET="lib"
elif [ -d src ]; then TARGET="src"
elif [ -d app ]; then TARGET="app"
else TARGET="."; fi
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("$TARGET")

for t in "${TARGETS[@]}"; do
  if [ ! -e "$t" ]; then
    echo "slop-grep: target not found: $t" >&2
    exit 2
  fi
done

list_files() {
  case "$STACK" in
    flutter)
      find "${TARGETS[@]}" -type f -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' \
        ! -path '*/build/*' ! -path '*/.dart_tool/*' ! -path '*/generated/*' -print0 ;;
    rn)
      find "${TARGETS[@]}" -type f \( -name '*.tsx' -o -name '*.ts' -o -name '*.jsx' -o -name '*.js' \) ! -name '*.d.ts' ! -name '*.test.*' \
        ! -path '*/node_modules/*' ! -path '*/ios/*' ! -path '*/android/*' ! -path '*/build/*' ! -path '*/.expo/*' ! -path '*/Pods/*' -print0 ;;
    web)
      find "${TARGETS[@]}" -type f \( -name '*.html' -o -name '*.css' -o -name '*.scss' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' -o -name '*.js' -o -name '*.ts' \) \
        ! -name '*.d.ts' ! -name '*.min.*' ! -name '*.test.*' \
        ! -path '*/node_modules/*' ! -path '*/dist/*' ! -path '*/build/*' ! -path '*/.next/*' ! -path '*/.nuxt/*' ! -path '*/coverage/*' ! -path '*/vendor/*' -print0 ;;
  esac
}

TOKENRE='(tokens?|theme|colors?|palette|motion|variables|design-system)\.(dart|ts|tsx|js|jsx|css|scss)$'

# Output of every rule is "file:line:snippet" lines.
grep_rule() { list_files | xargs -0 grep -HnE -- "$1" 2>/dev/null; }
grep_rule_i() { list_files | xargs -0 grep -HnEi -- "$1" 2>/dev/null; }
grep_rule_excl() { # file-exclusion regex, line regex
  list_files | tr '\0' '\n' | grep -vE "$1" | tr '\n' '\0' | xargs -0 grep -HnE -- "$2" 2>/dev/null
}
grep_rule_not() { # file-exclusion regex, line regex, line regex to drop (for example lines that use a token)
  list_files | tr '\0' '\n' | grep -vE "$1" | tr '\n' '\0' | xargs -0 grep -HnE -- "$2" 2>/dev/null | grep -vE -- "$3"
}
perl_rule() { # perl regex matched across lines
  RE="$1" list_files | RE="$1" xargs -0 perl -CSD -0777 -ne '
    my $re = qr/$ENV{RE}/s;
    while (/$re/g) {
      my $pos = $-[0];
      my $line = (substr($_, 0, $pos) =~ tr/\n//) + 1;
      my $s = substr($_, $pos, 80); $s =~ s/\s+/ /g;
      print "$ARGV:$line:$s\n";
    }' 2>/dev/null
}
spacing_flutter() { # numbers off the 4pt scale inside EdgeInsets / SizedBox
  list_files | xargs -0 perl -CSD -0777 -ne '
    while (/(EdgeInsets\.\w+|SizedBox)\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)/g) {
      my ($pos, $args) = ($-[0], $2);
      my $bad = 0;
      while ($args =~ /(?<![\w.])(\d+)(?:\.\d+)?(?![\w.])/g) {
        my $n = $1;
        $bad = 1 if ($n % 4 != 0 && $n != 2 && $n != 1);
      }
      next unless $bad;
      my $line = (substr($_, 0, $pos) =~ tr/\n//) + 1;
      my $s = substr($_, $pos, 70); $s =~ s/\s+/ /g;
      print "$ARGV:$line:$s\n";
    }' 2>/dev/null
}
spacing_px() { # padding / margin / gap values off the 4pt scale: React Native (bare numbers) and CSS (px) and Tailwind arbitrary values
  local unit="$1"   # "bare" for React Native, "px" for web
  list_files | UNIT="$unit" xargs -0 perl -CSD -ne '
    close ARGV if eof;
    my $unit = $ENV{UNIT};
    my $bad = 0;
    if (/\b(?:padding|margin|gap|row-gap|column-gap|rowGap|columnGap)[A-Za-z-]*\s*:\s*([^;}]+)/) {
      my $v = $1;
      if ($unit eq "bare") { while ($v =~ /(?<![\w.#-])(\d+)(?![\w.%])/g) { $bad = 1 if ($1 % 4 != 0 && $1 != 2 && $1 != 1); } }
      else { while ($v =~ /(?<![\w.#-])(\d+)px/g) { $bad = 1 if ($1 % 4 != 0 && $1 != 2 && $1 != 1); } }
    }
    if ($unit eq "px" && /\b(?:p|m|px|py|pt|pb|pl|pr|mx|my|mt|mb|ml|mr|gap)-\[(\d+)px\]/) { $bad = 1 if ($1 % 4 != 0 && $1 != 2 && $1 != 1); }
    if ($bad) { my $s = $_; $s =~ s/^\s+|\s+$//g; print "$ARGV:$.:" . substr($s, 0, 80) . "\n"; }
  ' 2>/dev/null
}

TOTAL=0
declare -a IDS=()

# A hit is muted only by "EXCEPTION to slop-grep/<id>: <reason of at least 8 letters>" on the same line or up to 8 lines above.
# Mute allowlists are not supported on purpose: the reason lives next to the code it excuses.
drop_excepted() { # id  (reads hits on stdin, prints the ones not excepted)
  local id="$1" hit file line from
  while IFS= read -r hit; do
    file="${hit%%:*}"; line="${hit#*:}"; line="${line%%:*}"
    case "$line" in ''|*[!0-9]*) printf '%s\n' "$hit"; continue ;; esac
    from=$((line > 8 ? line - 8 : 1))
    if sed -n "${from},${line}p" "$file" 2>/dev/null | grep -Eq "EXCEPTION to slop-grep/${id}: [A-Za-z][A-Za-z ,.;:()'-]{7,}"; then continue; fi
    printf '%s\n' "$hit"
  done
}

run() { # id  name  command...
  local id="$1" name="$2"; shift 2
  local out count
  out="$("$@" | drop_excepted "$id")"
  if [ -z "$out" ]; then count=0; else count=$(printf '%s\n' "$out" | grep -c .); fi
  TOTAL=$((TOTAL + count))
  IDS+=("$id $count")
  [ "$MODE" = "report" ] || return 0
  [ "$count" -eq 0 ] && return 0
  printf '\n%s  %s  (%s hits)\n' "$id" "$name" "$count"
  printf '%s\n' "$out" | head -n "$MAX" | sed 's/^/    /'
  [ "$count" -gt "$MAX" ] && printf '    ... %s more\n' $((count - MAX))
  return 0
}

[ "$MODE" = "report" ] && echo "slop-grep [$STACK] on: $TARGET   (candidates only - confirm each at file:line)"

EMOJI='[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B50}\x{2B06}\x{2B07}\x{2B05}\x{27A1}]'
HYPE='welcome back|supercharge|seamless|unlock|magic|revolutioni|game-changing|ai-powered|trusted by|loved by'
INSTR="[$Q\"][^$Q\"]*\\b(tap|click|swipe|press)( here)? to\\b"

# ---------- Flutter ----------
flutter_rules() {
  run S01 "emoji in code (icons, labels, copy)"            perl_rule "$EMOJI"
  run S02 "purple/violet/indigo palette (gradient tell)"   grep_rule_i 'Colors\.(purple|deepPurple|indigo|purpleAccent|deepPurpleAccent|pinkAccent)|0x[0-9a-f]{2}(8b5cf6|7c3aed|a855f7|6366f1|9333ea)'
  run S03 "gradients (hue-to-hue? text? background?)"       grep_rule '(Linear|Radial|Sweep)Gradient\('
  run S04 "glow shadow: BoxShadow with blur 20+"            perl_rule 'BoxShadow\s*\((?:[^()]|\([^()]*\))*?blurRadius:\s*(?:[2-9]\d|\d{3})'
  run S05 "hard-coded colors that skip dark mode"           grep_rule_excl "$TOKENRE" 'Colors\.(white|black)\b|Color\(0x[0-9A-Fa-f]{8}\)'
  run S06 "Material widgets on an iOS-first app"            grep_rule '\b(MaterialApp|Scaffold|AppBar|Drawer|FloatingActionButton|BottomNavigationBar|NavigationBar|ListTile|InkWell|SnackBar|MaterialPageRoute)\('
  run S07 "spacing off the 4pt scale"                       spacing_flutter
  run S08 "heavy font weights (w700-w900, bold)"            grep_rule 'FontWeight\.(w700|w800|w900|bold)\b'
  run S09 "forced uppercase labels"                         grep_rule '\.toUpperCase\(\)'
  run S10 "negative letter spacing"                         grep_rule 'letterSpacing:\s*-'
  run S11 "italic"                                          grep_rule 'FontStyle\.italic'
  run S12 "Dynamic Type disabled or pinned"                 grep_rule 'TextScaler\.noScaling|textScaleFactor:\s*1(\.0)?\b|TextScaler\.linear\(\s*1(\.0)?\s*\)'
  run S13 "exclamation marks in UI strings"                 grep_rule "Text\\(\\s*(const\\s+)?[$Q\"][^$Q\"]*![^$Q\"]*[$Q\"]"
  run S14 "greeting, hype or unverified-claim copy"         grep_rule_i "$HYPE"
  run S15 "instruction copy (tap/click/swipe to ...)"       grep_rule_i "$INSTR"
  run S16 "bounce or elastic curves"                        grep_rule 'Curves\.(bounce|elastic)[A-Za-z]*'
  run S17 "repeating animations (live things only)"         grep_rule '\.repeat\('
  run S18 "durations of 400ms or more"                      grep_rule_excl 'motion\.dart$' 'Duration\(\s*milliseconds:\s*([4-9][0-9]{2}|[0-9]{4,})\s*\)'
  run S19 "index-based stagger"                             grep_rule '(delay|Duration)[^;]*\*\s*(index|i)\b|\b(index|i)\s*\*\s*[0-9]+\s*\)?\s*(ms|milliseconds)'
  run S20 "spinner (skeleton instead?)"                     grep_rule 'CircularProgressIndicator|CupertinoActivityIndicator'
  run S21 "catch that swallows or returns empty (error=empty)" perl_rule 'catch\s*\([^)]*\)\s*\{\s*(return\s+(const\s+)?(<[^>]*>)?(\[\]|\{\}|null|0|\x27\x27|"")\s*;)?\s*\}'
  run S22 "blur / backdrop filter (glass: what is behind it?)" grep_rule 'BackdropFilter|ImageFilter\.blur'
  run S23 "dividers and Cards (divider/box everywhere?)"    grep_rule '\bDivider\(|\bCard\('
  run S24 "monospace fonts (only for ids/code?)"            grep_rule_i "monospace|courier|fontFamily:\\s*[$Q\"][^$Q\"]*mono"
  run S25 "scale animation that starts from zero (start 0.95 + opacity)" perl_rule 'ScaleTransition[^;]{0,220}?begin:\s*0(?:\.0)?\s*,\s*end:\s*1|Transform\.scale\([^;]{0,100}?scale:\s*0(?:\.0)?\s*[,)]'
  run S26 "inline Duration literal outside motion.dart (use a token)" grep_rule_excl 'motion\.dart$' 'Duration\(\s*(milliseconds|seconds):\s*[0-9]'
  run S27 "modal that cannot be dismissed (barrierDismissible: false)"  grep_rule 'barrierDismissible:\s*false'
  run S28 "orientation locked (HIG: support landscape unless task-specific)" grep_rule 'setPreferredOrientations'
  run S29 "back swipe blocked (PopScope canPop false / WillPopScope)" grep_rule 'PopScope\s*\(\s*canPop:\s*false|WillPopScope\s*\('
  run S30 "Material icons or hamburger on an iOS-first app"  grep_rule '\bIcons\.(menu|more_vert|[a-z][a-z_0-9]*)\b'
  run S31 "Android overscroll physics on iOS (use BouncingScrollPhysics)" grep_rule 'ClampingScrollPhysics'
}

# ---------- React Native ----------
rn_rules() {
  run S01 "emoji in code (icons, labels, copy)"            perl_rule "$EMOJI"
  run S02 "purple/violet/indigo palette (gradient tell)"   grep_rule_i "#(8b5cf6|7c3aed|a855f7|6366f1|9333ea|4f46e5|8b5cf6)\\b|[$Q\"](purple|violet|indigo|rebeccapurple|deeppink)[$Q\"]"
  run S03 "gradients (hue-to-hue? text? background?)"       grep_rule '<LinearGradient|expo-linear-gradient|react-native-linear-gradient|MaskedView'
  run S04 "glow shadow: shadowRadius 20+"                   grep_rule 'shadowRadius:\s*([2-9][0-9]|[0-9]{3})\b'
  run S05 "hard-coded colors that skip dark mode"           grep_rule_excl "$TOKENRE" "#[0-9A-Fa-f]{3,8}\\b|[$Q\"](white|black)[$Q\"]|rgba?\\("
  run S06 "Android or Material patterns on an iOS-first app" grep_rule 'android_ripple|TouchableNativeFeedback|DrawerLayoutAndroid|ToastAndroid|createDrawerNavigator|react-native-paper|FloatingActionButton|\bFAB\b|TouchableOpacity'
  run S07 "spacing off the 4pt scale"                       spacing_px bare
  run S08 "heavy font weights (700-900, bold)"              grep_rule "fontWeight:\\s*[$Q\"]?(700|800|900|bold)[$Q\"]?"
  run S09 "forced uppercase labels"                         grep_rule "\\.toUpperCase\\(\\)|textTransform:\\s*[$Q\"]uppercase"
  run S10 "negative letter spacing"                         grep_rule 'letterSpacing:\s*-'
  run S11 "italic"                                          grep_rule "fontStyle:\\s*[$Q\"]italic"
  run S12 "text scaling disabled or pinned"                 grep_rule 'allowFontScaling=\{false\}|allowFontScaling:\s*false|maxFontSizeMultiplier=\{1(\.0)?\}'
  run S13 "exclamation marks in UI strings"                 grep_rule ">[^<>{}]*[A-Za-z0-9]![^=<>{}]*<|(title|label|placeholder|headerTitle|description)=[$Q\"][^$Q\"]*[A-Za-z]![$Q\"]"
  run S14 "greeting, hype or unverified-claim copy"         grep_rule_i "$HYPE"
  run S15 "instruction copy (tap/click/swipe to ...)"       grep_rule_i "$INSTR"
  run S16 "bounce or elastic easing"                        grep_rule 'Easing\.(bounce|elastic|back)\b'
  run S17 "repeating animations (live things only)"         grep_rule 'withRepeat\(|Animated\.loop\(|loop:\s*true'
  run S18 "durations of 400ms or more"                      grep_rule_excl 'motion\.(ts|js)$' 'duration:\s*([4-9][0-9]{2}|[0-9]{4,})\b|\.duration\(\s*([4-9][0-9]{2}|[0-9]{4,})\s*\)'
  run S19 "index-based stagger"                             grep_rule '\.delay\(\s*(index|i)\s*\*|delay:\s*(index|i)\s*\*|\((index|i)\s*\*\s*[0-9]+\)'
  run S20 "spinner (skeleton instead?)"                     grep_rule 'ActivityIndicator'
  run S21 "catch that swallows or returns empty (error=empty)" perl_rule 'catch\s*(\([^)]*\))?\s*\{\s*(return\s+(\[\]|\{\}|null|0|\x27\x27|"")\s*;?)?\s*\}|\.catch\(\s*(\(\w*\)|\w*)\s*=>\s*(\[\]|\{\}|null|0)\s*\)'
  run S22 "blur / BlurView (glass: what is behind it?)"     grep_rule 'BlurView|blurRadius'
  run S23 "divider lines and card-shadow boxes everywhere"  grep_rule 'borderBottomWidth:\s*(StyleSheet\.hairlineWidth|1)\b|elevation:\s*[0-9]+'
  run S24 "monospace fonts (only for ids/code?)"            grep_rule_i "fontFamily:\\s*[$Q\"][^$Q\"]*(mono|courier|menlo)"
  run S25 "scale animation that starts from zero (start 0.95 + opacity)" grep_rule 'scale:\s*0\s*[,}]|withSpring\(\s*0\s*[,)]|from=\{\{[^}]*scale:\s*0\b'
  run S26 "inline duration literal outside motion.ts (use a token)" grep_rule_excl 'motion\.(ts|js)$' 'duration:\s*[0-9]|\.duration\(\s*[0-9]'
  run S27 "modal that cannot be dismissed"                  grep_rule 'onRequestClose=\{\(\)\s*=>\s*\{\s*\}\}|gestureEnabled:\s*false'
  run S28 "orientation locked (support landscape unless task-specific)" grep_rule "orientation:\\s*[$Q\"]portrait|ScreenOrientation\\.lockAsync|Orientation\\.lock"
  run S29 "back swipe or back button blocked"               grep_rule 'BackHandler\.addEventListener|usePreventRemove\(|beforeRemove|gestureEnabled:\s*false'
  run S30 "icon font sets or hamburger instead of SF Symbols" grep_rule_i "@expo/vector-icons|MaterialIcons|MaterialCommunityIcons|FontAwesome|hamburger|name=[$Q\"]menu[$Q\"]"
  run S31 "Android overscroll or bounce disabled on iOS"    grep_rule 'overScrollMode|bounces=\{false\}|bounces:\s*false'
  run S32 "TouchableOpacity or Dimensions.get (use Pressable and the hooks)" grep_rule 'Dimensions\.get\('
  run S33 "hard-coded status bar or safe-area offsets"      grep_rule 'paddingTop:\s*(20|24|44|47|50|54|59)\b|marginTop:\s*(20|44|47|50|54|59)\b|StatusBar\.currentHeight'
}

# ---------- Web (HTML, CSS, React, Vue, Svelte, Tailwind) ----------
web_rules() {
  run S01 "emoji in code (icons, labels, copy)"            perl_rule "$EMOJI"
  run S02 "purple/violet/indigo palette (gradient tell)"   grep_rule_i '#(8b5cf6|7c3aed|a855f7|6366f1|9333ea|4f46e5)\b|\b(rebeccapurple|blueviolet)\b|\b(bg|text|from|to|via|border|ring)-(purple|violet|indigo|fuchsia)-[0-9]{3}'
  run S03 "gradients (hue-to-hue? text? background?)"       grep_rule '(linear|radial|conic)-gradient\(|\bbg-gradient-to-|\b(from|via|to)-[a-z]+-[0-9]{3}\b|bg-clip-text'
  run S04 "glow shadow: box-shadow with blur 20+"           grep_rule 'box-shadow:[^;]*\b[0-9]+(px)?[ ]+[0-9]+(px)?[ ]+([2-9][0-9]|[0-9]{3})px|\bdrop-shadow-\['
  run S05 "hard-coded colors outside the token file"        grep_rule_not "$TOKENRE" '#[0-9A-Fa-f]{3,8}\b|rgba?\(|\b(color|background(-color)?)[ ]*:[ ]*(white|black)\b' '^[^:]*:[0-9]+:[[:space:]]*--[A-Za-z0-9-]+[[:space:]]*:'
  run S06 "div/span as button, link to #, missing semantics" perl_rule '<(?:div|span|li)\b[^>]*\bonClick\s*=(?![^>]*\brole\s*=)|<a\b[^>]*\bhref\s*=\s*["\x27]#["\x27]'
  run S07 "spacing off the 4px scale"                       spacing_px px
  run S08 "heavy font weights (700-900, bold)"              grep_rule 'font-weight:\s*(700|800|900|bold)\b|\bfont-(bold|extrabold|black)\b|fontWeight:\s*(700|800|900)\b'
  run S09 "forced uppercase labels"                         grep_rule 'text-transform:\s*uppercase|\buppercase\b|\.toUpperCase\(\)'
  run S10 "negative letter spacing"                         grep_rule 'letter-spacing:\s*-|\btracking-(tight|tighter)\b'
  run S11 "italic"                                          grep_rule 'font-style:\s*italic|\bitalic\b'
  run S12 "text zoom disabled or text pinned in px"         grep_rule 'user-scalable\s*=\s*(no|0)|maximum-scale\s*=\s*1(\.0)?\b|text-size-adjust:\s*none'
  run S13 "exclamation marks in UI strings"                 grep_rule ">[^<>{}]*[A-Za-z0-9]![^=<>{}]*<"
  run S14 "greeting, hype or unverified-claim copy"         grep_rule_i "$HYPE"
  run S15 "instruction copy (tap/click/swipe to ...)"       grep_rule_i "$INSTR|>[^<>]*\\b(click|tap) here\\b"
  run S16 "bounce, elastic or overshoot easing"             grep_rule_i 'cubic-bezier\([^)]*(,[ ]*-|1\.[1-9])|ease-?(in|out)-?(back|bounce|elastic)|\bbounce\b|\belastic\b'
  run S17 "infinite animations (live things only)"          grep_rule 'animation-iteration-count:\s*infinite|animation:[^;]*\binfinite\b|\banimate-(pulse|bounce|ping|spin)\b'
  run S18 "durations of 400ms or more"                      grep_rule_not "$TOKENRE" '(transition|animation)[^;{]*\b(0?\.[4-9][0-9]*s|[1-9][0-9]*(\.[0-9]+)?s|[4-9][0-9]{2}ms|[0-9]{4,}ms)\b|\bduration-(500|700|1000)\b' '--(dur|duration)'
  run S19 "index-based stagger computed in script"          grep_rule '(animationDelay|transitionDelay)[^;]{0,60}(index|\bi)\s*\*|delay:\s*(index|i)\s*\*'
  run S20 "spinner (skeleton instead?)"                     grep_rule_i 'animate-spin|<Spinner|class(Name)?=["'"$Q"'][^"'"$Q"']*\bspinner\b'
  run S21 "catch that swallows or returns empty (error=empty)" perl_rule 'catch\s*(\([^)]*\))?\s*\{\s*(return\s+(\[\]|\{\}|null|0|\x27\x27|"")\s*;?)?\s*\}|\.catch\(\s*(\(\w*\)|\w*)\s*=>\s*(\[\]|\{\}|null|0)\s*\)'
  run S22 "backdrop blur (glass: what is behind it?)"       grep_rule 'backdrop-filter|\bbackdrop-blur|filter:\s*blur|\bblur-(sm|md|lg|xl|2xl|3xl)\b'
  run S23 "rounded-2xl shadow on every box; dividers everywhere" grep_rule '\brounded-(2xl|3xl)\b[^"'"$Q"']*\bshadow|\bshadow-(md|lg|xl|2xl)\b[^"'"$Q"']*\brounded-(2xl|3xl)\b|\bdivide-y\b'
  run S24 "monospace fonts (only for ids/code?)"            grep_rule_i 'font-family:[^;]*(monospace|courier|menlo)|\bfont-mono\b'
  run S25 "scale animation that starts from zero (start 0.95 + opacity)" grep_rule 'scale\(\s*0(\.0+)?\s*\)|\bscale-0\b|scale:\s*0(\.0+)?\s*[;,}]'
  run S26 "literal duration instead of a token"             grep_rule_not "$TOKENRE" '(transition|animation)[^;{]*[0-9]m?s\b' 'var\(--|--(dur|duration)'
  run S27 "modal: confirm Escape, visible close and focus return" grep_rule 'aria-modal\s*=|role\s*=\s*["'"$Q"']dialog|\.showModal\('
  run S28 "orientation locked"                              grep_rule 'orientation\.lock|screen\.lockOrientation'
  run S29 "back button trapped"                             grep_rule 'beforeunload|history\.pushState\(\s*null'
  run S30 "hamburger or icon-font reflex"                   grep_rule_i 'hamburger|menu-toggle|\bfa-[a-z-]+|class(Name)?=["'"$Q"'][^"'"$Q"']*\bburger\b'
  run S31 "focus ring removed"                              grep_rule 'outline:\s*(none|0)\b|\boutline-none\b|focus:outline-none'
  run S32 "transition: all"                                 grep_rule 'transition:\s*all\b|transition-property:\s*all|\btransition-all\b'
  run S33 "images without alt text"                         perl_rule '<img\b(?![^>]*\balt\s*=)[^>]*>'
  run S34 "100vh (use dvh on mobile browsers)"              grep_rule '\b100vh\b|\bh-screen\b|\bmin-h-screen\b'
  run S35 "animating layout properties (use transform)"     grep_rule 'transition:[^;]*\b(width|height|top|left|right|bottom|margin|padding)\b'
}

case "$STACK" in
  flutter) flutter_rules ;;
  rn) rn_rules ;;
  web) web_rules ;;
esac

case "$MODE" in
  ids) printf '%s\n' "${IDS[@]}" ;;
  report) printf '\n%s candidate hits across %s rules. Next: open the screen and confirm each at file:line.\n' "$TOTAL" "${#IDS[@]}" ;;
esac
exit 0
