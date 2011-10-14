ERL          = erl
SRC_DIR      = $(CURDIR)/src
EBIN_DIR     = $(CURDIR)/ebin

.PHONY: all clean shell

all:
	$(ERL) -noinput -eval "case make:all() of up_to_date -> halt(0); error -> halt(1) end."

clean:
	rm -f $(EBIN_DIR)/*.beam

run: all
	./bin/ermacs

shell: all
	$(ERL) -pa $(EBIN_DIR)
