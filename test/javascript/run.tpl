#!/bin/sh -e

# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

SRC_DIR=%abs_top_srcdir%
SCRIPT_DIR=$SRC_DIR/share/www/script
JS_TEST_DIR=$SRC_DIR/test/javascript

COUCHJS=%abs_top_builddir%/src/couchdb/priv/couchjs

if [ "$#" -eq 0 ];
then
    TEST_SRC="$SCRIPT_DIR/test/*.js"
else
    TEST_SRC="$1"
    if [ ! -f $TEST_SRC ]; then
        TEST_SRC="$SCRIPT_DIR/test/$1"
        if [ ! -f $TEST_SRC ]; then
            TEST_SRC="$SCRIPT_DIR/test/$1.js"
            if [ ! -f $TEST_SRC ]; then
                echo "file $1 does not exist"
                exit
            fi
        fi
    fi
fi



# stop CouchDB on exit from various signals
abort() {
	trap - 0
	./utils/run -d
	exit 2
}

# start CouchDB
if [ -z $COUCHDB_NO_START ]; then
        make dev
	trap 'abort' 0 1 2 3 4 6 8 15
	./utils/run -b -r 1
	sleep 1 # give it a sec
fi

cat $SCRIPT_DIR/json2.js \
	$SCRIPT_DIR/sha1.js \
	$SCRIPT_DIR/oauth.js \
	$SCRIPT_DIR/couch.js \
	$SCRIPT_DIR/couch_test_runner.js \
	$SCRIPT_DIR/couch_tests.js \
	$TEST_SRC \
	$JS_TEST_DIR/couch_http.js \
	$JS_TEST_DIR/cli_runner.js \
    | $COUCHJS -H -

if [ -z $COUCHDB_NO_START ]; then
	# stop CouchDB
	./utils/run -d
	trap - 0
fi
