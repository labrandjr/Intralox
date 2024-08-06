#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT711VLSC  ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ Jun/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtros definidos para não gerar SC na execução do MRP.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT711VLSC()

Local aArea := GetArea()
Local zProd := PARAMIXB[3]
Local lSCok := .T.
Local zGrpX := AllTrim(SuperGetMv("MV_ZZGRUPX",.F.,"PV,XXX"))

If FWCodEmp() $("99,U6")
	zGrupo := Posicione("SB1",1,xFilial("SB1")+zProd,"B1_GRUPO")
	If AllTrim(zGrupo) $(zGrpX)
		lSCok := .F.
	Endif
Endif	

RestArea(aArea)

Return(lSCok)
