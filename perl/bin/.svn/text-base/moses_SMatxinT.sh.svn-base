#!/bin/bash

MOSES=/home/cristinae/soft/mosesdecoder/bin/moses

INPUT="";
MOSES_PARAMS="";
NBEST_FILE="";
NBEST=100;

#parametroak irakurri 
while [ $# -gt 0 ]; do
    case "$1" in
	-config)
	    shift
	    CFG_FILE=$1
	    shift
	    ;;
	-f)
	    shift
	    CFG_FILE=$1
	    shift
	    ;;
	-input-file)
	    shift
	    INPUT=$1
	    shift
	    ;;
	-i)
	    shift
	    INPUT=$1
	    shift
	    ;;
	-n-best-list)
	    shift
	    NBEST_FILE=$1
	    shift
	    NBEST=$1
	    shift
	    ;;
	*)
	    MOSES_PARAMS="$MOSES_PARAMS $1"
	    shift
	    ;;
    esac
done

#INPUT=/home/cristinae/pln/sistemes/matxin/chunks1.1.c/devADMIN/test.ADMINdevel.2013_02_20.SMatxinT
if [ -z "$CFG_FILE" ]; then
    echo "You have to specify a configuration file..."
    exit
fi

if [ -z "$INPUT" ]; then
    CMD="$MOSES -config $CFG_FILE  -inputtype 0 -show-weights > ./features.list"
    $CMD
    INPUT=.input_file.$$
    cat > $INPUT
    exit
fi

$MOSES -config $CFG_FILE $MOSES_PARAMS -i $INPUT -n-best-list .nbest_file.f.$$ $NBEST > .moses_out.f.$$
#$MOSES -config $CFG_FILE $MOSES_PARAMS  -n-best-list .nbest_file.f.$$ $NBEST < $INPUT > .moses_out.f.$$

sed -e 's/\.freeling/\.malt/' < $CFG_FILE > .malt_conf.$$

$MOSES -config .malt_conf.$$ $MOSES_PARAMS -i $INPUT.malt -n-best-list .nbest_file.m.$$ $NBEST > .moses_out.m.$$
#$MOSES -config .malt_conf.$$ $MOSES_PARAMS  -n-best-list .nbest_file.m.$$ $NBEST < $INPUT.malt > .moses_out.m.$$
 
#ull, que depen del numero de features
cat .nbest_file.[mf].$$ | sort -t\| -k1,1n -k10,10rn > .nbest_file.$$

if [ -n "$NBEST_FILE" ]; then
    mv .nbest_file.$$ $NBEST_FILE
fi

rm .malt_conf.$$ .nbest_file.[mf].$$
