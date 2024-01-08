SHELL := /bin/bash
KERNELVERSION  ?= $(shell uname --kernel-release)
KSRC := /lib/modules/$(KERNELVERSION)/build

INSTALLDIR := /lib/modules/$(KERNELVERSION)/kernel/drivers/gpio
MODDESTDIR := /lib/modules/$(KERNELVERSION)/kernel/drivers/gpio
DKMSDIR := /usr/src/gpio-f7188x-alt-1.0.0

obj-m += gpio-f7188x-alt.o

all:
	$(MAKE) -C $(KSRC) M=$(shell pwd) modules

clean:
	$(MAKE) -C $(KSRC) M=$(shell pwd) clean

install: all
	@rm --force --verbose $(INSTALLDIR)/gpio-f7188x-alt.ko
	@mkdir --parent --verbose $(MODDESTDIR)
	@install --preserve-timestamps -D --mode=644 *.ko $(INSTALLDIR)
	@depmod --all $(KVER)
	@printf "%s\n" "Installion finished."

uninstall:
	@rm -f $(INSTALLDIR)/gpio-f7188x-alt.ko
	@depmod --all
	@printf "%s\n" "Uninstall finished."

dkms: all
	if [ -d $(DKMSDIR) ]; then\
    	rm --recursive $(DKMSDIR)/*;\
        cp --recursive * $(DKMSDIR)/;\
	else \
		mkdir --verbose $(DKMSDIR);\
        cp --recursive * $(DKMSDIR);\
		dkms add -m gpio-f7188x-alt -v 1.0.0;\
	fi
	dkms build gpio-f7188x-alt --force -v 1.0.0
	dkms install gpio-f7188x-alt --force -v 1.0.0
	printf "%s\n" "Loading module"
	modprobe gpio-f7188x-alt
