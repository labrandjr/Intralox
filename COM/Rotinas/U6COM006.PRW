#include "rwmake.ch"
#include "protheus.ch"
#include "xmlxfun.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TRFAXML  ¦ Autor ¦ Fábrica ERP.BR  ¦ Data    ¦ Maio/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere os arquivos Xml para Cloud diretório Importador. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRFAXML()

Local cPerg   := "TRFAXML"
Local lImpXml := GetMv("MV_IMPXML")

If lImpXml
	If Pergunte(cPerg,.T.)
		MsgRun("Aguarde, transferindo arquivos para o diretório do Importador","Processando",{|| TrfXmlve2() })
	Endif
Else
	MsgInfo("Importador de Xml não habilitado (MV_IMPXML).")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TrfXmlve2  ¦ Autor ¦  Fábrica ERP.BR   ¦ Data ¦ Maio/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Transfere arquivos Xml para o servidor.					  ¦¦¦
¦¦¦          ¦ Utiliza diretório original mapeado e não move os arquivos. ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function TrfXmlve2()

Local cDirGeral := AllTrim(GetMv("MV_NGINN"))+"\"
Local nTotArq   := 0
Local _xml

// Diretório origem selecionado
cPatXml := AllTrim(mv_par01)
If Substr(cPatXml,Len(Alltrim(cPatXml)),1) <> "\"
	cPatXml += "\" 
Endif

// Monta um array com todos os arquivos
aArqXml := Directory(cPatXml + "*.xml", "D")

// Percorre os arquivos e transfere para o servidor
For _xml := 1 to Len(aArqXml)
	cFileXml := Alltrim(cPatXml + aArqXml[_xml][1])
	If aArqXml[_xml][3] >= mv_par02 .And. aArqXml[_xml][3] <= mv_par03
		__CopyFile( cFileXml, cDirGeral + aArqXml[_xml][1] )
		nTotArq += 1
	Endif	
Next _xml

If Len(aArqXml) == 0
	MsgAlert("Arquivos não localizados no diretório informado.")
Else
	MsgInfo(AllTrim(STR(nTotArq))+" arquivo(s) transferido(s).")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPDGRP2   ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ Ago/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualização do grupo 2 na solictação de compras.		  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function UPDGRP2()
MsgAlert("Empresa "+FWCodEmp())
If FWCodEmp() $("99,U6")
	If MsgYesNo("Confirma atualização do Grupo2 na Solicitação de Compras ?")
		MsgRun("Aguarde, atualizando grupo 2...","Processando",{|| ProcGrp2() })
	Endif	
Endif
Return

Static Function ProcGrp2()
DbSelectArea("SC1")
SC1->(DbGotop())
While !Eof()
	//
	RecLock("SC1",.F.)
	SC1->C1_GRPRD  := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_GRUPO")
	SC1->C1_ZZGRP2 := Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_ZZGRP2")
	MsUnLock()
	//
	DbSelectArea("SC1")
	SC1->(DbSkip())
Enddo
Return
