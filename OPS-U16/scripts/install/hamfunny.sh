#!/bin/bash 

echo "Hien thi ra noi dung"
echo ""

## Dinh nghia ham
function hamfunny {

	if [ "$1" == "controller" ]; then
		echo "dung gia tri nhap vao roi"
	else
		echo "Sai roi"

	fi
}

## Goi ham

hamfunny $1