.PHONY=clean

SOURCE_DIR=src
SOURCE_NAME=Blink
TARGET_DIR=target
ARTIFACT_NAME=blink

SOURCE=${SOURCE_DIR}/${SOURCE_NAME}.elm
ARTIFACT=${TARGET_DIR}/${ARTIFACT_NAME}.html

${ARTIFACT}: ${SOURCE} ${SOURCE_DIR}/*.elm
	elm make --optimize --output=$@ $<

${TARGET_DIR}:
	mkdir -p $@

clean:
	rm -f ${ARTIFACT}
