#include "rwmake.ch"
#include "protheus.ch"
#include "xmlxfun.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � TRFAXML  � Autor � F�brica ERP.BR  � Data    � Maio/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Transfere os arquivos Xml para Cloud diret�rio Importador. ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TRFAXML()

Local cPerg   := "TRFAXML"
Local lImpXml := GetMv("MV_IMPXML")

If lImpXml
	If Pergunte(cPerg,.T.)
		MsgRun("Aguarde, transferindo arquivos para o diret�rio do Importador","Processando",{|| TrfXmlve2() })
	Endif
Else
	MsgInfo("Importador de Xml n�o habilitado (MV_IMPXML).")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � TrfXmlve2  � Autor �  F�brica ERP.BR   � Data � Maio/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Transfere arquivos Xml para o servidor.					  ���
���          � Utiliza diret�rio original mapeado e n�o move os arquivos. ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TrfXmlve2()

Local cDirGeral := AllTrim(GetMv("MV_NGINN"))+"\"
Local nTotArq   := 0
Local _xml

// Diret�rio origem selecionado
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
	MsgAlert("Arquivos n�o localizados no diret�rio informado.")
Else
	MsgInfo(AllTrim(STR(nTotArq))+" arquivo(s) transferido(s).")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � UPDGRP2   � Autor � F�brica ERPBR   �   Data  � Ago/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Atualiza��o do grupo 2 na solicta��o de compras.		  	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function UPDGRP2()
MsgAlert("Empresa "+FWCodEmp())
If FWCodEmp() $("99,U6")
	If MsgYesNo("Confirma atualiza��o do Grupo2 na Solicita��o de Compras ?")
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
