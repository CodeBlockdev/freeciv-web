#!/bin/sh

# - metatype will be replaced by patch #4485

PATCHLIST="caravan_fixes1 city_fixes city_impr_fix2 city_name_bugfix city-naming-change city_fixes2 citytools_changes current_research_cost diplchanges goto_1 goto_attack1 goto_fix_1 goto_fix_2 govt-fix map-settings map_size_change metachange metatype metasrvflag packets orders_aborted orders_invalid2 text_fixes turnchange unithand-change2 webclient-ai-attitude freeciv-svn-webclient-changes network-rewrite-1 fcnet_packets misc_devversion_sync scenario_ruleset savegame savegame2 maphand_ch serverside_extra_assign libtoolize_no_symlinks spacerace city_disbandable ai_traits_crash"

apply_patch() {
  echo "*** Applying $1.patch ***"
  if ! patch -u -p1 -d freeciv < patches/$1.patch ; then
    echo "APPLYING PATCH $1.patch FAILED!"
    return 1
  fi
  echo "=== $1.patch applied ==="
}

# APPLY_UNTIL feature is used when rebasing the patches, and the working directory
# is needed to get to correct patch level easily.
if test "x$1" != "x" ; then
  APPLY_UNTIL="$1"
  au_found=false

  for patch in $PATCHLIST
  do
    if test "x$patch" = "x$APPLY_UNTIL" ; then
      au_found=true
    fi
  done
  if test "x$au_found" != "xtrue" ; then
    echo "There's no such patch as \"$APPLY_UNTIL\"" >&2
    exit 1
  fi
else
  APPLY_UNTIL=""
fi

. ./version.txt

if ! grep "NETWORK_CAPSTRING_MANDATORY=\"$ORIGCAPSTR\"" freeciv/fc_version 2>/dev/null >/dev/null ; then
  echo "Capstring to be replaced does not match one given in version.txt" >&2
  exit 1
fi

sed "s/$ORIGCAPSTR/$WEBCAPSTR/" freeciv/fc_version > freeciv/fc_version.tmp
mv freeciv/fc_version.tmp freeciv/fc_version
chmod a+x freeciv/fc_version

for patch in $PATCHLIST
do
  if test "x$patch" = "x$APPLY_UNTIL" ; then
    echo "$patch not applied as requested to stop"
    break
  fi
  if ! apply_patch $patch ; then
    echo "Patching failed ($patch.patch)" >&2
    exit 1
  fi
done
