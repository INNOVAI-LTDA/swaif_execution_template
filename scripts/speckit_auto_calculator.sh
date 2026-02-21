#!/usr/bin/env bash
set -euo pipefail

# Parâmetros
FEATURE_SLUG="${1:-calculator-python}"
ISSUE_NUMBER="${2:-0}"
AGENT="copilot"  # Troque para o agente desejado

FEATURE_DIR="specs/${FEATURE_SLUG}"

# 1. Inicializa projeto (se necessário)
if [[ ! -d .specify ]]; then
  specify init . --ai "$AGENT"
fi

# 2. Gera especificação
specify run speckit.specify "Crie uma calculadora em Python com entrada e saída no terminal." --ai "$AGENT"

# 3. Gera plano técnico
specify run speckit.plan --ai "$AGENT"

# 4. Gera tarefas
specify run speckit.tasks --ai "$AGENT"

# 5. Gera implementação
specify run speckit.implement --ai "$AGENT"

# 6. Commita artefatos gerados
git add "$FEATURE_DIR" .github/agents .specify/templates
git commit -m "swaif(auto): ${FEATURE_SLUG} (issue #${ISSUE_NUMBER})"
git push --force-with-lease origin "swaif/${FEATURE_SLUG}"

echo "Fluxo Speckit automatizado concluído para feature: $FEATURE_SLUG"
