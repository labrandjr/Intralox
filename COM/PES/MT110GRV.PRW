#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT110GRV  ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ Ago/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação complementar na Solicitação de Compras.		  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT110GRV()

Local aArea  := GetArea()
Local b1Grp2 := SB1->(FieldPos("B1_ZZGRP2")) > 0
Local c1Grp2 := SC1->(FieldPos("C1_ZZGRP2")) > 0

If FWCodEmp() $("99,U6")
	If b1Grp2 .And. c1Grp2
		RecLock("SC1",.F.)
		SC1->C1_GRPRD  := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_GRUPO")
		SC1->C1_ZZGRP2 := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_ZZGRP2")
		MsUnLock()
	Endif	
Endif	

RestArea(aArea)

Return
