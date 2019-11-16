.PHONY: all package clean 0 1 2 3 hints

all:
	$(MAKE) -C src/ocaml-output
	$(MAKE) -C ulib
	$(MAKE) -C ulib/ml

package:
	git clean -ffdx .
	$(MAKE) -C src/ocaml-output package

clean:
	$(MAKE) -C ulib clean
	$(MAKE) -C src/ocaml-output clean

# Shortcuts for developers

# Build the F# version
0:
	$(MAKE) -C src/

# Build the OCaml snapshot. NOTE: This will not build the standard library,
# nor tests, and native tactics will not run
1:
	$(MAKE) -C src/ocaml-output ../../bin/fstar.exe

# Bootstrap just the compiler, not the library and tests;
# fastest way to incrementally build a patch to the compiler
boot:
	$(MAKE) -C src/ ocaml
	$(MAKE) -C src/ocaml-output ../../bin/fstar.exe

# Generate a new OCaml snapshot
2:
	$(MAKE) -C src fstar-ocaml

# Build the snapshot and then regen, i.e. 1 + 2
3:
	$(MAKE) -C src ocaml-fstar-ocaml

# Regenerate all hints for the standard library and regression test suite
hints:
	OTHERFLAGS=--record_hints $(MAKE) -C ulib/
	OTHERFLAGS=--record_hints $(MAKE) -C ulib/ml
	OTHERFLAGS=--record_hints $(MAKE) -C src/ uregressions
