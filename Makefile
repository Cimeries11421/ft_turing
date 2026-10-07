# ============================================================
# Configuration
# ============================================================

NAME := ft_turing

SOURCES := \
	main.ml \
	parsing/parser.ml

OBJECTS := $(SOURCES:.ml=.cmx)
BYTE_OBJECTS := $(SOURCES:.ml=.cmo)

OPAM := opam

OCAMLC := $(OPAM) exec -- ocamlfind ocamlc
OCAMLOPT := $(OPAM) exec -- ocamlfind ocamlopt
OCAMLDEP := $(OPAM) exec -- ocamlfind ocamldep

# Bibliothèques OCaml utilisées par le projet
OPAM_PACKAGES := \
	ocaml \
	ocamlfind \
	core \
	core_unix \
	ppx_jane

OCAML_PACKAGES := core,core_unix

# ============================================================
# Couleurs
# ============================================================

GREEN	:= \033[32m
YELLOW	:= \033[33m
RED		:= \033[31m
BLUE	:= \033[34m
GRAY	:= \033[90m
RESET	:= \033[0m

# ============================================================
# Compilation par defaut
# ============================================================

.PHONY: all
all: dependencies $(NAME)

# ============================================================
# Vérification / installation des dépendances
# ============================================================

.PHONY: dependencies

dependencies:
	@command -v $(OPAM) >/dev/null 2>&1 || \
		(echo "$(RED)Erreur : opam n'est pas installé et ne peut pas être installé par OPAM.$(RESET)"; \
		echo "Installez opam avant de lancer make."; \
		exit 1)

	@echo "$(GRAY)==> Vérification/Installation des dépendances...$(RESET)"
	@$(OPAM) install -y $(OPAM_PACKAGES)

# ============================================================
# Compilation native avec ocamlopt
# ============================================================

$(NAME): $(SOURCES)
	@echo "$(YELLOW)==> Compilation native avec ocamlopt...$(RESET)"
	$(OCAMLFIND) $(OCAMLOPT) \
		-package $(OCAML_PACKAGES) \
		-linkpkg \
		-o $@ \
		$(OBJECTS)
	@echo "$(GREEN)==> Compilation terminée : ./$(NAME)$(RESET)"

%.cmx: %.ml
	@echo "$(YELLOW)==> Compilation de $<...$(RESET)"
	$(OCAMLFIND) $(OCAMLOPT) \
		-package $(OCAML_PACKAGES) \
		-c \
		$<
# ============================================================
# Compilation bytecode avec ocamlc
# ============================================================

.PHONY: byte

byte: dependencies
	@echo "$(YELLOW)==> Compilation bytecode avec ocamlc...$(RESET)"
	$(OCAMLFIND) $(OCAMLC) \
		-package $(OCAML_PACKAGES) \
		-linkpkg \
		-o $(NAME).byte \
		$(BYTE_OBJECTS)
	@echo "$(GREEN)==> Compilation terminée : ./$(NAME).byte$(RESET)"

%.cmo: %.ml
	@echo "$(YELLOW)==> Compilation bytecode de $<...$(RESET)"
	$(OCAMLFIND) $(OCAMLC) \
		-package $(OCAML_PACKAGES) \
		-c \
		$<

# ============================================================
# Dépendances OCaml
# ============================================================

.PHONY: depend

depend:
	@echo "$(GRAY)==> Calcul des dépendances...$(RESET)"
	$(OCAMLDEP) -native $(SOURCES) > .depend

# ============================================================
# Nettoyage
# ============================================================

.PHONY: clean
clean:
	@echo "$(YELLOW)==> Nettoyage...$(RESET)"
	rm -f $(NAME)
	rm -f $(NAME).byte
	rm -f $(OBJECTS)
	find . -name "*.cmi" -delete
	find . -name "*.cmo" -delete
	find . -name "*.cmx" -delete
	find . -name "*.o" -delete
	@echo "$(GREEN)==> Nettoyage terminé.$(RESET)"

# ============================================================
# Recompilation complète
# ============================================================

.PHONY: re
re: clean all

# ============================================================
# Exécution
# ============================================================

.PHONY: run
run: all
	./$(NAME)

# ============================================================
# Inclusion des dépendances
# ============================================================

-include .depend