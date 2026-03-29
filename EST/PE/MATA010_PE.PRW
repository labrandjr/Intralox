#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "fwmvcdef.ch"

/*/{Protheus.doc} 
@function MATA010_PE
@description MVC Cadastro de Produtos
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
/*/
User Function ITEM()

Local aParam   := PARAMIXB
Local xRet     := .T.
Local oModel   := ""
Local cIdPonto := ""
Local cIdModel := ""
Local lIsGrid  := .F.
//Local nLinha   := 0
//Local nQtdLinh := 0
//Local cMsg     := ""
//Local nX

If aParam <> Nil

	oModel   := aParam[1]
	cIdPonto := aParam[2]
	cIdModel := aParam[3]
	lIsGrid  := ( Len( aParam ) > 3 )

	If cIdPonto == "MODELPOS"
		/*
		cMsg := "Chamada na validação total do modelo." + CRLF
		cMsg += "ID " + cIdModel + CRLF
		xRet := ApMsgYesNo(cMsg + "Continua?")
		*/
	ElseIf cIdPonto == "FORMPOS"
		/*
		cMsg := "Chamada na validação total do formulário." + CRLF
		cMsg += "ID " + cIdModel + CRLF
		If lIsGrid
			cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
			cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
		Else
			cMsg += "É um FORMFIELD" + CRLF
		EndIf
		xRet := ApMsgYesNo(cMsg + "Continua?")
		*/
		If oModel:GetOperation() == 4
			If SB1->B1_MSBLQL <> "1"
				If Alltrim(FwFldGet("B1_MSBLQL")) == "1"
					lMovOk := ChkMovProd(SB1->B1_COD)
					If !lMovOk
						MsgInfo("O produto possui movimentações em aberto.","Aviso")
						xRet := .F.
					Endif
				Endif 
			Endif
		Endif
		//
	ElseIf cIdPonto == "FORMLINEPRE"
		/*
		If aParam[5] == "DELETE"
			cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
			cMsg += "Onde esta se tentando deletar a linha" + CRLF
			cMsg += "ID " + cIdModel + CRLF
			cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
			cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
			xRet := ApMsgYesNo(cMsg + " Continua?")
		EndIf
		*/
	ElseIf cIdPonto == "FORMLINEPOS"
		/*
		cMsg := "Chamada na validação da linha do formulário." + CRLF
		cMsg += "ID " + cIdModel + CRLF
		cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
		cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
		xRet := ApMsgYesNo(cMsg + " Continua?")
		*/
	ElseIf cIdPonto == "MODELCOMMITTTS"
		//ApMsgInfo("Chamada após a gravação total do modelo e dentro da transação.")
	ElseIf cIdPonto == "MODELCOMMITNTTS"
		//ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")
	ElseIf cIdPonto == "FORMCOMMITTTSPRE"
		//ApMsgInfo("Chamada após a gravação da tabela do formulário.")
	ElseIf cIdPonto == "FORMCOMMITTTSPOS"
		//ApMsgInfo("Chamada após a gravação da tabela do formulário.")
	ElseIf cIdPonto == "MODELCANCEL"
		//cMsg := "Deseja realmente sair?"
		//xRet := ApMsgYesNo(cMsg)
	ElseIf cIdPonto == "BUTTONBAR"
		//xRet := {{"Certificado BOM", "SALVAR", { || u_IntCertBom() }}}
	EndIf

Endif

Return(xRet)

/*/{Protheus.doc} 
@function ChkMovProd
@description Checagem de movimentos
@type function
@author	Fábrica ERP.BR
@since 15/01/2026
@version P12
@database MSSQL
/*/
Static Function ChkMovProd(cProduto)

Local lRetMov := .F.
Local lRetChk := .T.

// Checa movimentos na empresa logada
lRetMov := ChkMovtos(cEmpAnt+"0",cProduto)

If !lRetMov // Caso não haja, checa movimentos nas demais empresas onde o SB1 é compartilhado no SX2

	// Tabela cadastro de produtos usado na empresa logada
	cQuery := " SELECT X2_ARQUIVO "
	cQuery += " FROM SX2"+cEmpAnt+"0"
	cQuery += " WHERE X2_CHAVE = 'SB1' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQX2", .F., .T.)
	cTabSb1 := AllTrim(SQX2->X2_ARQUIVO)
	SQX2->(DbCloseArea())

	lRetMov := ChkEmpresas(cTabSb1,cProduto)

Endif

If lRetMov
	lRetChk := .F. // Caso haja movimentos, não permite bloquear o produto
Endif

Return(lRetChk)

/*/{Protheus.doc} 
@function ChkEmpresas
@description Checagem nas demais empresas
@type function
@author	Fábrica ERP.BR
@since 15/01/2026
@version P12
@database MSSQL
/*/
Static Function ChkEmpresas(cTabSb1,cProduto)

Local lRetMov := .F.
Local aAllGrp := FWAllGrpCompany()
Local cEmpOut := ""
Local _emp

For _emp := 1 to Len(aAllGrp) // Empresas

	If aAllGrp[_emp] $(cEmpOut)
		Loop
	Endif

	cEmpGrp := aAllGrp[_emp]
	
	// Tabela cadastro de produtos usado na empresa do grupo
	cQuery := " SELECT X2_ARQUIVO "
	cQuery += " FROM SX2"+cEmpGrp+"0"
	cQuery += " WHERE X2_CHAVE = 'SB1' "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQX2", .F., .T.)
	cSb1Sx2 := AllTrim(SQX2->X2_ARQUIVO)
	SQX2->(DbCloseArea())

	If cSb1Sx2 == cTabSb1
		// Checa movimentos na empresa do grupo
		lRetMov := ChkMovtos(cEmpGrp+"0",cProduto)
		If lRetMov
			Exit
		Endif
	Endif

Next _emp

Return(lRetMov)

/*/{Protheus.doc} 
@function ChkMovProd
@description Checagem de movimentos
@type function
@author	Fábrica ERP.BR
@since 15/01/2026
@version P12
@database MSSQL
/*/
Static Function ChkMovtos(cEmpMov,cProduto)

Local cEOL := CHR(13)+CHR(10)
Local cMsgExt := "Movimentos localizados (Empresa "+Substr(cEmpMov,1,2)+"):"+cEOL
Local lRetMov := .F.

// 1. Solicitação de compras
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM SC1"+cEmpMov
cQuery += " WHERE C1_PRODUTO = '"+cProduto+"' "
cQuery += " AND C1_QUJE > 0 "
cQuery += " AND C1_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQSC1", .F., .T.)
lTemSc1 := (SQSC1->SOMA > 0)
SQSC1->(DbCloseArea())
If lTemSc1
	cMsgExt += cEOL+"Solic.Compras"
	lRetMov := .T.
Endif

// 2. Cotações
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM SC8"+cEmpMov
cQuery += " WHERE C8_PRODUTO = '"+cProduto+"' "
cQuery += " AND C8_NUMPED = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQSC8", .F., .T.)
lTemSc8 := (SQSC8->SOMA > 0)
SQSC8->(DbCloseArea())
If lTemSc8
	cMsgExt += cEOL+"Cotações"
	lRetMov := .T.
Endif

// 3. Pedido de compras
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM SC7"+cEmpMov
cQuery += " WHERE C7_PRODUTO = '"+cProduto+"' "
cQuery += " AND C7_QUJE > 0 "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQSC7", .F., .T.)
lTemSc7 := (SQSC7->SOMA > 0)
SQSC7->(DbCloseArea())
If lTemSc7
	cMsgExt += cEOL+"Ped.Compras"
	lRetMov := .T.
Endif

// 4. Pré-Documento de entrada
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM SD1"+cEmpMov
cQuery += " WHERE D1_COD = '"+cProduto+"' "
cQuery += " AND D1_TES = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQSD1", .F., .T.)
lTemSd1 := (SQSD1->SOMA > 0)
SQSD1->(DbCloseArea())
If lTemSd1
	cMsgExt += cEOL+"Pré-Documento"
	lRetMov := .T.
Endif

// 5. Medições
cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM CNE"+cEmpMov+" CNE "
cQuery += " INNER JOIN CND"+cEmpMov+" CND ON CNE.CNE_FILIAL = CND.CND_FILIAL AND CNE.CNE_CONTRA = CND.CND_CONTRA AND CNE.CNE_REVISA = CND.CND_REVISA AND CNE.CNE_NUMMED = CND.CND_NUMMED AND CND.D_E_L_E_T_ <> '*' "
cQuery += " WHERE CNE.CNE_PRODUT = '"+cProduto+"' "
cQuery += " AND CND.CND_SITUAC = 'A' "
cQuery += " AND CNE.D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQCNE", .F., .T.)
lTemCne := (SQCNE->SOMA > 0)
SQCNE->(DbCloseArea())
If lTemCne
	cMsgExt += cEOL+"Medições"
	lRetMov := .T.
Endif

If lRetMov
	If !IsBlind()
		MsgInfo(cMsgExt,"Aviso")
	Endif
Endif

Return(lRetMov)
