#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDef.CH'

user function AxIncSa5(cFornece, cLoja, cProd,cNomFor,cPrdForn,cPrdDesc,cUnid, cxFator,nxQtdFat)
	Local aErro  := {}
	Local nOpcao := 3
	Local lRet   := .T.
	Local oModel := FWLoadModel('MATA061')

	Default cFornece := ''
	Default cLoja    := ''
	Default cProd    := ''
	Default cNomFor  := ''
	Default cPrdForn := ''
	Default cPrdDesc := ''
	Default cUnid    := ''
	Default cxFator  := ''
	Default nxQtdFat := 0

	If(FindFunction( "U_APONROT") .AND. FwAliasInDic("SZ8"), u_AponRot(),"") // apontador de usabilidade de rotina

		cForn    := Padr(cFornece, TamSX3("A5_FORNECE")[1])
		cLoja    := Padr(cLoja, TamSX3("A5_LOJA")[1])
		cD1Cod   := Padr(cProd,TamSX3("A5_PRODUTO")[1])
		cZ1Cod   := Padr(cPrdForn,TamSX3("A5_CODPRF")[1])
		cA5Uni   := Padr(Posicione( 'SB1' , 1, FwxFilial( 'SB1' ) +cProd, "B1_UM" ),TamSX3("A5_UNID")[1])
		cNomFor  := Padr(cNomFor,TamSX3("A5_NOMEFOR")[1])
		cPrdDesc := Padr(cPrdDesc,TamSX3("A5_NOMPROD")[1])
	//	cUnid    := '' //AvkEY(cUnid, 'A5_UNID' )
	//	cxFator  := AvkEY(cxFator, 'A5_XFATOR' )
	//	nxQtdFat := AvkEY(nxQtdFat, 'A5_XQTDFAT' )

		cA5Uni   := If( !Empty(cUnid), cUnid,cA5Uni )

		If Empty(cNomFor)
			cNomFor := Padr(Posicione('SA2', 1, FwxFilial('SA2') +cForn +cLoja , "A2_NOME" ),TamSX3("A5_NOMEFOR")[1])
		EndIf

		If Empty(cPrdDesc)
			cPrdDesc := Padr(SB1->B1_DESC,TamSX3("A5_NOMPROD")[1])
		EndIf

		dbSelectArea("SA5")
		SA5->(dbSetOrder(1))    // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD
		If SA5->(dbSeek(xFilial("SA5")+cForn+cLoja+cD1Cod))
			nOpcao := 4
		Endif

		oSA5MdField := oModel:getModel("MdFieldSA5")
		oSA5MdGrid  := oModel:getModel("MdGridSA5")

		oModel:SetOperation(nOpcao)
		oModel:Activate()

		If nOpcao  == 3
			oSA5MdGrid:SetValue("A5_FORNECE",cForn)
			oSA5MdGrid:SetValue("A5_LOJA",cLoja)
			oSA5MdField:SetValue("A5_PRODUTO",cD1Cod)
			oSA5MdGrid:SetValue("A5_CODPRF",cZ1Cod)
			oSA5MdGrid:SetValue("A5_UNID",cA5Uni)
			oSA5MdGrid:SetValue("A5_NOMPROD",cPrdDesc)
			oSA5MdGrid:SetValue("A5_NOMEFOR",cNomFor)
			oSA5MdGrid:SetValue("A5_XFATOR",cxFator)
			oSA5MdGrid:SetValue("A5_XQTDFAT",nxQtdFat)
		Else
			oSA5MdGrid:SetValue("A5_NOMPROD",cPrdDesc)
			oSA5MdGrid:SetValue("A5_NOMEFOR",cNomFor)
			oSA5MdGrid:SetValue("A5_UNID",cA5Uni)
			oSA5MdGrid:SetValue("A5_XFATOR",cxFator)
			oSA5MdGrid:SetValue("A5_XQTDFAT",nxQtdFat)
		Endif

		If oModel:VldData()
			If !oModel:CommitData()
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf

		If !lRet
			aErro := oModel:GetErrorMessage()
			cMsg := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
			cMsg += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
			cMsg += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
			cMsg += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
			cMsg += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
			cMsg += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
			cMsg += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
			cMsg += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
			cMsg += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
			cMsg += "  SA5   ;'" + cForn+"-"+cLoja + " ;'" + cD1Cod + " ;' " + Padr(cZ1Cod,30) + " ;' ERRO: " + ArrTokStr(aErro)  +  CRLF
		Endif

		oModel:DeActivate()
		oModel:Destroy()

		Return lRet
