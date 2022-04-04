WEBPAGE_DIR=docs
SUB_DIRECTORIES=blink decode localisation
CLEAN_TARGETS=$(addsuffix clean,$(SUB_DIRECTORIES))

.PHONY: all clean ${SUB_DIRECTORIES} ${CLEAN_TARGETS}

all: ${WEBPAGE_DIR}

${SUB_DIRECTORIES}:
	${MAKE} -C $@

${WEBPAGE_DIR}: ${SUB_DIRECTORIES}
	mkdir -p $@
	echo "<meta http-equiv=refresh content=0;url=localisation.html>" > $@/index.html
	for directory in ${SUB_DIRECTORIES} ; \
	do \
		cp -rf $$directory/target/* $@ ; \
	done

clean: ${CLEAN_TARGETS}
	@echo "finished cleaning"

%clean: %
	${MAKE} -C $< clean
