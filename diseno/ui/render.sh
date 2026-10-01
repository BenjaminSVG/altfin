#!/bin/bash
# Renderiza cada pantalla a PNG con Edge headless
cd "$(dirname "$0")"; mkdir -p png
E="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
W=$(pwd -W)
r(){ "$E" --headless --disable-gpu --hide-scrollbars --virtual-time-budget=6000 --screenshot="$W/png/$1.png" --window-size=$2,$3 "file:///$W/s.html?n=$1" >/dev/null 2>&1; }
i=0
for n in bienvenida sueldo perfil inicio gasto movimientos presupuesto metas inversion informes finn ajustes inicio_oscuro; do i=$((i+1)); r $n 470 920; mv png/$n.png png/$(printf %02d $i)-$n.png; done
r escritorio 1340 880; mv png/escritorio.png png/14-escritorio.png
r sistema 1180 1180; mv png/sistema.png png/15-sistema.png
r iconos 1160 760; mv png/iconos.png png/16-iconos.png
ls png
