
#alias crear y entrar a la carpera
mkcd(){
  mkdir -p $1 && cd $1
}


#a lias listar en formato tablas
listar() {
  local es_largo=0 argumento
  for argumento in "$@"; do
    [[ "$argumento" == -*l* ]] && es_largo=1
  done

  if (( es_largo )); then
    command ls "$@" | awk '
      function repetir(caracter, veces,  i, salida){ salida=""; for(i=0;i<veces;i++) salida=salida caracter; return salida }
      BEGIN { num_columnas=7; split("Permissions Links Owner Group Size Date Name", titulos, " ") }
      {
        if ($0 ~ /^total /) next
        fila++
        celda[1,fila]=$1; celda[2,fila]=$2; celda[3,fila]=$3; celda[4,fila]=$4; celda[5,fila]=$5
        celda[6,fila]=$6 " " $7 " " $8
        nombre=$9; for(pos=10;pos<=NF;pos++) nombre=nombre "" $pos
        celda[7,fila]=nombre
        for(col=1;col<=num_columnas;col++) if(length(celda[col,fila])>anchos[col]) anchos[col]=length(celda[col,fila])
      }
      END {
        for(col=1;col<=num_columnas;col++) if(length(titulos[col])>anchos[col]) anchos[col]=length(titulos[col])
        borde="+"; for(col=1;col<=num_columnas;col++) borde=borde repetir("-",anchos[col]+2) "+"
        print borde
        linea="|"; for(col=1;col<=num_columnas;col++) linea=linea sprintf(" %-*s |",anchos[col],titulos[col]); print linea
        print borde
        for(f=1;f<=fila;f++){ linea="|"; for(col=1;col<=num_columnas;col++) linea=linea sprintf(" %-*s |",anchos[col],celda[col,f]); print linea }
        print borde
      }
    '
  else
    command ls "$@"
  fi
}