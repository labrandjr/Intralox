#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � A650OKSC   � Autor � F�brica ERPBR   �   Data  � Jun/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Filtros definidos para n�o gerar SC na abertura de OP.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function A650OKSC()

Local aArea := GetArea()
Local zProd := PARAMIXB[1]
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
