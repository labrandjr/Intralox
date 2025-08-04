#include "protheus.ch"
#include "tbiconn.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

Static cFtnPad := "IXFAT01"
Static cTitRel := "Relatorio de Pedidos"
Static cDesRel := "Este relatório permite imprimir a relação de Follow Up."
// Static _cVersao := cFtnPad+" v2.07"
// Static _cDtVersao := "08-07-2022"

Static _cVersao := cFtnPad+" v2.08"
Static _cDtVersao := "17-07-2024"

Static aVetCpo := {} // campos do relatorio
// Static cTabFollow := "TABFOLLOW"


/*====================================================================================
Autor: 			Aldo Barbosa dos Santos
Data: 			18/03/2022
Consultoria: 	HLB - Prox
Uso: 			INTRALOX
Info: 			Relatório de Follow Up
*=====================================================================================*/
User Function IXFAT01()
	Private cPerg := PadR(cFtnPad,10)

	Private aCabRel := {}
	Private aIteRel := {}
	Private oFWMsExcel := Nil
	Private cArquivo   := "" //GetTempPath()+cFtnPad+"_"+GetNextAlias()+".xml"

	// ativa os atalhos do Help da rotina
	Versao(.T.)

	fCriaPerg(cPerg)
 
	SC5->( Dbsetorder(1))
	SC6->( Dbsetorder(1))

	If Pergunte(cPerg,.T.) .and. MsgYesNo("Confirma o processamento do relatório?", "Relatório Follow Up")
		// campos do relatorio
		aVetCpo := {}
		Aadd(aVetCpo,{"SC5","C5_NUM"		,'Número do Pedido de Venda'	,"LEFT", 	{|| QRY->C5_NUM 	} ,1} )	
		Aadd(aVetCpo,{"SC5","C6_ITEM"		,'Item Pedido de Venda'			,"LEFT", 	{|| QRY->C6_ITEM	} ,1} )
		Aadd(aVetCpo,{"SC5","C5_EMISSAO"	,'Data do Pedido de Venda'		,"CENTER", 	{|| QRY->C5_EMISSAO	} ,4} )	
		Aadd(aVetCpo,{"SC6","C6_ENTREG"		,'Data de Entrega'				,"CENTER", 	{|| QRY->C6_ENTREG	} ,4} )	
		Aadd(aVetCpo,{"SC6","C6_QTDVEN"		,'Quant.Vendida'				,"RIGHT", 	{|| QRY->C6_QTDVEN	} ,2} )	
		Aadd(aVetCpo,{"SC6","F2_DOC"		,'Num. Nf Saida'				,"LEFT", 	{|| QRY->F2_DOC		} ,1} )
		Aadd(aVetCpo,{"SF2","F2_EMISSAO"	,'Dt Emissão NF Saida'			,"CENTER", 	{|| QRY->F2_EMISSAO	} ,4} )
		Aadd(aVetCpo,{"SF2","F2_EMINFE"		,'Dt Transmissão NF Saida'		,"CENTER", 	{|| QRY->F2_EMINFE	} ,4} )
		Aadd(aVetCpo,{"SC6","C6_TES"		,'TES do Faturamento'			,"LEFT", 	{|| QRY->C6_TES		} ,1} )
		Aadd(aVetCpo,{"SC2","C2_NUM"		,'Número da OP'					,"LEFT", 	{|| QRY->C2_NUM		} ,1} )
		Aadd(aVetCpo,{"SC2","C2_EMISSAO"	,'Data da OP'					,"CENTER", 	{|| QRY->C2_EMISSAO	} ,4} )
		Aadd(aVetCpo,{"SC1","C1_NUM"		,'Número da SC'					,"LEFT", 	{|| QRY->C1_NUM		} ,1} )
		Aadd(aVetCpo,{"SC1","C1_ITEM"		,'Item da SC'					,"LEFT", 	{|| QRY->C1_ITEM	} ,1} )
		Aadd(aVetCpo,{"SC1","C1_OBS"		,'Observação SC'				,"LEFT", 	{|| QRY->C1_OBS		} ,1} )
		Aadd(aVetCpo,{"SC1","C1_EMISSAO"	,'Data da SC'					,"CENTER", 	{|| QRY->C1_EMISSAO	} ,4} )
		Aadd(aVetCpo,{"SC1","C1_DATPRF"		,'Data de Necessidade'			,"CENTER", 	{|| QRY->C1_DATPRF	} ,1} )
		Aadd(aVetCpo,{"SC1","C1_QUANT"		,'Quant.Solicitada'				,"RIGHT", 	{|| QRY->C1_QUANT	} ,2} )
		Aadd(aVetCpo,{"SC1","C1_PRODUTO"	,'Código do item'				,"LEFT", 	{|| QRY->PRODUTO	} ,1} )
		Aadd(aVetCpo,{"SB1","B1_DESC"		,'Descrição'					,"LEFT", 	{|| QRY->B1_DESC	} ,1} )
		Aadd(aVetCpo,{"SB1","B1_GRUPO"		,'Cod. Grupo Produto'			,"LEFT", 	{|| QRY->B1_GRUPO	} ,1} )
		//		Aadd(aVetCpo,{"SBM","BM_DESC"		,'Descr. Grupo Produto'			,"LEFT", 	{|| QRY->BM_DESC	} ,1} )
		Aadd(aVetCpo,{"SC7","C7_NUM"		,'Número do PC'					,"LEFT", 	{|| QRY->C7_NUM		} ,1} )
		Aadd(aVetCpo,{"SC7","C7_ITEM"		,'Item PC'						,"LEFT", 	{|| QRY->C7_ITEM	} ,1} )
		Aadd(aVetCpo,{"SC7","C7_QUANT"		,'Quantidade PC'				,"RIGHT", 	{|| QRY->C7_QUANT	} ,2} )
		Aadd(aVetCpo,{"SC7","C7_QUJE"		,'Quant.Entregue PC'			,"RIGHT", 	{|| QRY->C7_QUJE	} ,2} )
		Aadd(aVetCpo,{"SC7","C7_RESIDUO"	,'Falta Receber PC'				,"RIGHT", 	{|| if(QRY->(C7_QUANT-C7_QUJE)>0,QRY->(C7_QUANT-C7_QUJE),0) } ,2} )
		Aadd(aVetCpo,{"SC7","C7_MOEDA"		,'Moeda'						,"RIGHT", 	{|| DescricaoMoeda(QRY->C7_MOEDA) } ,2} )
		Aadd(aVetCpo,{"SC7","C7_PRECO"		,'Valor unitário'				,"RIGHT", 	{|| QRY->C7_PRECO	} ,2} )
		Aadd(aVetCpo,{"SC7","C7_TOTAL"		,'Valor Total'					,"RIGHT", 	{|| QRY->C7_TOTAL	} ,2} )
		Aadd(aVetCpo,{"SC7","C7_PICM"		,'ICMS% PC'						,"RIGHT", 	{|| QRY->C7_PICM	} ,2} )
		Aadd(aVetCpo,{"SC7","C7_IPI"		,'IPI% PC'						,"RIGHT", 	{|| QRY->C7_IPI		} ,2} )
		Aadd(aVetCpo,{"SC7","C7_EMISSAO"	,'Data PC'						,"CENTER", 	{|| QRY->C7_EMISSAO	} ,4} )
		Aadd(aVetCpo,{"SC7","C1_FORNECE"	,'Fornecedor'					,"LEFT", 	{|| QRY->FORNECE	} ,1} )
		Aadd(aVetCpo,{"SA2","A2_NOME"		,'Nome do Fornecedor'			,"LEFT", 	{|| QRY->A2_NOME   	} ,1} )
		Aadd(aVetCpo,{"SC7","C7_DATPRF"		,'Data de Entrega'				,"CENTER", 	{|| QRY->C7_DATPRF	} ,4} )
		Aadd(aVetCpo,{"SC7","C7_TPFRETE"	,'Frete combinado (CIF/FOB)'	,"LEFT",	{|| QRY->C7_TPFRETE	} ,1} )
		Aadd(aVetCpo,{"SF1","F1_DOC"		,'Número NF Entrada'			,"LEFT", 	{|| QRY->F1_DOC		} ,1} )
		Aadd(aVetCpo,{"SF1","F1_EMISSAO"	,'Data Emissão NF Entrada'		,"CENTER", 	{|| QRY->F1_EMISSAO	} ,4} )
		Aadd(aVetCpo,{"SF1","F1_DTDIGIT"	,'Entrada da NF Entrada'		,"CENTER", 	{|| QRY->F1_DTDIGIT	} ,4} )
		Aadd(aVetCpo,{"SD1","D1_QUANT"		,'Quantidade NF Entrada'		,"RIGHT", 	{|| QRY->D1_QUANT 	} ,2} )
		//           TABELA   CAMPO           TITULO                        ALINHAMENTO      DADO            TIPO(1=Texto;2=Numerico;4=Data)

		cArquivo := GetTempPath()+cFtnPad+"_"+GetNextAlias()+".xml"
		MsgRun("Aguarde.....", "Gerando Relatório",{|| ProcessaFollow()})

		/*			if Len(aIteRel) == 0
						MsgAlert("Não foram localizados dados para os filtros informados.", cFtnPad)
					Else	
						MsgRun("Aguarde.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"GETDADOS","RELATÓRIO FOLLOW UP",aCabRel,aIteRel}})})
					Endif	
		*/
		//		Endif
	Endif

	Versao(.F.)
		
Return


/*====================================================================================
Autor: 			Aldo Barbosa dos Santos
Data: 			18/03/2022
Consultoria: 	HLB - Prox
Uso: 			INTRALOX
Info: 			Perguntas do relatório
*=====================================================================================*/
Static Function fCriaPerg(_cPerg)
	Local j, i
	Local aRegistros:={}

	AADD(aRegistros,{_cPerg,"01","Pedido Venda De ?"	,"","","mv_ch1","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par01","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"02","Pedido Venda Ate ?"	,"","","mv_ch2","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par02","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"03","Dt.Ped.Venda De ?"	,"","","mv_ch3","D",08				,00,00,"G",""	,"Mv_Par03","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"04","Dt.Ped.Venda Ate?"	,"","","mv_ch4","D",08				,00,00,"G",""	,"Mv_Par04","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"05","Pedido Compra De ?"	,"","","mv_ch5","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par05","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"06","Pedido Compra Ate ?"	,"","","mv_ch6","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par06","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"07","Dt.Ped.Compra De ?"	,"","","mv_ch7","D",08				,00,00,"G",""	,"Mv_Par07","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"08","Dt.Ped.Compra Ate?"	,"","","mv_ch8","D",08				,00,00,"G",""	,"Mv_Par08","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"09","Solicitação De ?"		,"","","mv_ch9","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par09","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"10","Solicitação Ate ?"	,"","","mv_cha","C",Len(SC7->C7_NUM),00,00,"G",""	,"Mv_Par10","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"11","Dt.Solicitação De ?"	,"","","mv_chb","D",08				,00,00,"G",""	,"Mv_Par11","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"12","Dt.Solicitação Ate?"	,"","","mv_chc","D",08				,00,00,"G",""	,"Mv_Par12","","","",""        ,"","","",""               ,"","","",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"13","Com Residuo?"			,"","","mv_chd","C",08				,00,00,"C",""	,"Mv_Par13","1=Sim","","","",""  ,"2=Não","","","",""   ,"3=Todos",""     ,"","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{_cPerg,"14","Com Solicit.Compra?"	,"","","mv_che","C",08				,00,00,"C",""	,"Mv_Par14","1=Sim","","","",""  ,"2=Não","","","",""   ,"3=Todos",""     ,"","","","","","","","","","","","","","","","","",""})

	// GUILHERME LEONEL - 17/07/2024
	// CHAMADO 17362
	// CLIENTE PEDIU PARA INCLUIR UM NOVO PARAMETRO SEPARADO PARA OS CASOS COM E SEM RESIDUO
	// NOVO PARAMETRO 15 INCLUIDO DIRETO NO CONFIGURADOR DEVIDO AO ACESSO DIRETO NO SX1 PARA VERSOES 33 E SUPERIOES

	SX1->( dbSetOrder(1))
	For i := 1 to Len(aRegistros)
		If SX1->( ! DbSeek(aRegistros[i,1]+aRegistros[i,2]))
			RecLock("SX1",.T.)
			For j:=1 to SX1->( FCount()) 
				SX1->( FieldPut(j,aRegistros[i,j]))
			Next
			SX1->( MsUnlock())
		Endif
	Next

Return(Nil)


Static Function DescricaoMoeda(_nMoeda)
	Local cVarMv := "MV_MOEDA"+CValToChar(_nMoeda)
	Local cRet   := ""

	cRet := CValToChar(_nMoeda)+"-"+Getmv(cVarMv,,"MOEDA")
Return( cRet )


/*====================================================================================
Autor: 			Aldo Barbosa dos Santos
Data: 			18/03/2022
Consultoria: 	HLB - Prox
Uso: 			INTRALOX
Info: 			Processamento do relatório
*=====================================================================================*/
Static function ProcessaFollow()
	Local aArea := SX3->( GetArea())
	Local aIte   := {}
	Local nE

	Private cNumPvDe   := Alltrim(MV_PAR01)
	Private cNumPvAte  := Alltrim(MV_PAR02)
	Private cEmiPvDe   := Dtos(MV_PAR03)
	Private cEmiPvAte  := Dtos(MV_PAR04)
	Private cNumPcDe   := Alltrim(MV_PAR05)
	Private cNumPcAte  := Alltrim(MV_PAR06)
	Private cEmiPcDe   := Dtos(MV_PAR07)
	Private cEmiPcAte  := Dtos(MV_PAR08)
	Private cNumScDe   := Alltrim(MV_PAR09)
	Private cNumScAte  := Alltrim(MV_PAR10)
	Private cEmiScDe   := Dtos(MV_PAR11)
	Private cEmiScAte  := Dtos(MV_PAR12)
	Private cResiduo := cValtoChar(MV_PAR13) // 1=Sim;2=Não;3=Todos
	Private cSolicit := cValtoChar(MV_PAR14) // 1=Sim;2=Não;3=Todos

	// GUILHERME LEONEL - 17/07/2024
	// CHAMADO 17362
	// CLIENTE PEDIU PARA INCLUIR UM NOVO PARAMETRO SEPARADO PARA OS CASOS COM E SEM RESIDUO
	PRIVATE cElimPc := CVALTOCHAR(MV_PAR15) // 1=Sim ; 2=Não ; 3=Todos

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	// gravando os parametros na aba
	cAbaPar := "PARAMETROS"
	cTitPar := "Parâmetros do Relatório"
	oFWMsExcel:AddworkSheet(cAbaPar) //Não utilizar número junto com sinal de menos. Ex.: 1-
	oFWMsExcel:AddTable(cAbaPar,cTitPar)
	oFWMsExcel:AddColumn(cAbaPar,cTitPar,"Parâmetro",1)
	oFWMsExcel:AddColumn(cAbaPar,cTitPar,"Conteúdo"	,1)

	SX1->( Dbseek(cPerg))
	Do While SX1->( ! Eof()) .and. SX1->X1_GRUPO == cPerg
		uConteudo := &(Alltrim(SX1->X1_VAR01))
		if ValType(uConteudo) == "D"
			uConteudo := Dtoc(uConteudo)
		elseif ValType(uConteudo) == "N"
			uConteudo := SX1->&("X1_DEF0"+Str(uConteudo,1))
		Endif	
		oFWMsExcel:AddRow(cAbaPar,cTitPar,{SX1->X1_PERGUNT, uConteudo})
		SX1->( Dbskip())
	Enddo

	// inicio da aba do relatorio
	cAbaExcel := "RELATORIO"
	cTitExcel := "Relatório Follow Up - INTRALOX"
	oFWMsExcel:AddworkSheet(cAbaExcel) //Não utilizar número junto com sinal de menos. Ex.: 1-

	//Criando a Tabela
	oFWMsExcel:AddTable(cAbaExcel,cTitExcel)

	// Criando as Colunas ro relatorio
	For nE := 1 to Len(aVetCpo)
		nAlign  := if(aVetCpo[nE,4]=="LEFT",1,if(aVetCpo[nE,4]=="RIGHT",3,2))
		nFormat := aVetCpo[nE,6]
		oFWMsExcel:AddColumn(cAbaExcel,cTitExcel,aVetCpo[nE,3], nAlign, nFormat)
	//                      cWorkSheet, cTable  ,  cColumn    , nAlign, nFormat     , lTotal
	Next
	oFWMsExcel:AddColumn(cAbaExcel,cTitExcel,"_", nAlign, nFormat)

	/*	// definindo os campos do relatorio
		SX3->( DbSetOrder(2))
		For nE := 1 to Len(aVetCpo)
			SX3->( Dbseek(aVetCpo[nE,2]))
			Aadd(aCabRel, {aVetCpo[nE,3],SX3->X3_TIPO,SX3->X3_TAMANHO, SX3->X3_DECIMAL})
		Next
		Aadd(aCabRel, {" ","C",10, 0})
	*/

	// query principal do relatório estará no alias QRY
	MontaQuery()

	// coloca os dados no vetor para geração do excel
	aIteRel := {}
	Do While QRY->(!Eof())
		lImprime := .T.
		if cSolicit == '2' .and.   ! Empty(QRY->C1_NUM) 
			lImprime := .F.
		Elseif cSolicit == '1' .and. Empty(QRY->C1_NUM) 
			lImprime := .F.
		Elseif  cResiduo == "2" .and. QRY->( C7_QUANT - C7_QUJE) > 0 
			lImprime := .F.
		Elseif  cResiduo == "1" .and. QRY->(C7_QUANT - C7_QUJE) = 0 
			lImprime := .F.
		Endif

		aIte := {}
		For nE := 1 to Len(aVetCpo)
			bDado := aVetCpo[nE,5]
			uDado := Eval(bDado)
			if Type("uDado") == "C"
				uDado := Alltrim(Strtran(Strtran(uDado,"'"," "),'"'," "))
			Endif	
			Aadd(aIte, uDado)
		Next
		Aadd(aIte, " ")
		//		Aadd(aIteRel,aClone(aIte))	

		oFWMsExcel:AddRow(cAbaExcel,cTitExcel,aIte)

		QRY->(dbSkip())
	EndDo

	//	aIteRel := Asort(aIteRel,,,{|a,b| a[1]+a[12] < b[1]+b[12]})

	if Select("QRY") <> 0
		QRY->( DbcloseArea())
	Endif	

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
			
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()				// Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)			// Abre uma planilha
	oExcel:SetVisible(.T.)					// Visualiza a planilha
	oExcel:Destroy()						// Encerra o processo do gerenciador de tarefas

	RestArea(aArea)
Return


/*====================================================================================
Autor: 			Aldo Barbosa dos Santos
Data: 			18/03/2022
Consultoria: 	HLB - Prox
Uso: 			INTRALOX
Info: 			Monta a query principal, conta os registros e executa a query 
*=====================================================================================*/
Static Function MontaQuery(nModo)
	Local cQuery := ""
	Local cFilSA2 := xFilial("SA2")
	Local cFilSB1 := xFilial("SB1")
	// Local cFilSBM := xFilial("SBM")
	Local cCampo := cSelect := ""
	Local nE 

	Default nModo := 1  // 1=Partindo do Pedido de Vendas; 2=Partindo do Pedido de Compras

	// fecha o alias se estiver aberto
	if Select("QRY") <> 0
		QRY->( DbcloseArea())
	Endif

	//if nModo == 1

	//if TCCANOPEN( cTabFollow )
	//	TcSqlExec("Drop TABLE "+cTabFollow)
	//Endif	

	// query principal original
	cQuery += "  SELECT DISTINCT * FROM ("
	
	// PEDIDO DE VENDAS - CARREGA PROCESSO PARTINDO DOS PEDIDOS DE VENDAS
	cSelect := "SELECT DISTINCT C5_FILIAL AS FILIAL, "

	For nE := 1 to Len(aVetCpo)
		cCampo := aVetCpo[nE,2]
		if cCampo == "C1_PRODUTO"
			cCampo := "C6_PRODUTO AS PRODUTO"
		Elseif cCampo == "C1_FORNECE"
			cCampo := "C1_FORNECE AS FORNECE"
		Elseif cCampo == "C1_NUM"
			cCampo := "NVL(C1_NUM,' ') AS C1_NUM"
		Elseif cCampo == "F1_DOC"
			cCampo := "NVL(F1_DOC,' ') AS F1_DOC"
		Elseif cCampo == "D1_QUANT"
			cCampo := "NVL(D1_QUANT,0) AS D1_QUANT"
		Endif	
		cSelect += " "+cCampo+" , "
	Next

	cQuery += Left(cSelect,Len(cSelect)-3) +" "+Chr(13)
	cQuery += "  FROM "+RetSqlName("SC5")+"      C5 "
	cQuery += "  JOIN "+RetSqlName("SC6")+" 	 C6 ON C6.D_E_L_E_T_ <> '*' And C6_FILIAL = C5_FILIAL AND C6_NUM   = C5_NUM "+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC1")+" C1 ON C1.D_E_L_E_T_ <> '*' AND C1_FILIAL = C6_FILIAL AND C1_NUM   = C6_NUMSC   AND C1_ITEM    = C6_ITEMSC "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC7")+" C7 ON C7.D_E_L_E_T_ <> '*' AND C7_FILIAL = C6_FILIAL AND C7_NUMSC = C1_NUM     AND C7_ITEMSC  = C1_ITEM    AND C7_PRODUTO = C1_PRODUTO "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC2")+" C2 ON C6.D_E_L_E_T_ <> '*' And C2_FILIAL = C6_FILIAL And C2_NUM   = C6_NUMOP   AND C2_ITEM    = C6_ITEMOP "	+Chr(13)
	
	if Empty(cFilSB1)
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = '  ' And B1_COD   = C6_PRODUTO "	+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = C6_FILIAL And B1_COD   = C6_PRODUTO "	+Chr(13)
	Endif

	//	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" BM ON BM.D_E_L_E_T_ <> '*' And BM_FILIAL = '"+cFilSBM+"' And BM_GRUPO = B1_GRUPO "	+Chr(13)
	cQuery += "  LEFT JOIN (SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_EMINFE  FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_ <> '*' AND   F2_TIPO = 'N' ) F2 ON F2_FILIAL = C6_FILIAL AND F2_DOC   = C5_NOTA  AND F2_SERIE = C5_SERIE " + Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SD2")+" D2 ON D2.D_E_L_E_T_ <> '*' And D2_FILIAL = F2_FILIAL AND D2_DOC   = F2_DOC     AND D2_COD     = C6_PRODUTO "	+Chr(13)
	
	if Empty(cFilSA2)
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = '  '       AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = C6_FILIAL AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Endif

	cQuery += "  LEFT JOIN "+RetSqlName("SD1")+" D1 ON D1.D_E_L_E_T_ <> '*' And D1_FILIAL = C6_FILIAL AND D1_NUMPV = C6_NUM     AND D1_ITEMPV  = C6_ITEM "		+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SF1")+" F1 ON F1.D_E_L_E_T_ <> '*' And F1_FILIAL = D1_FILIAL AND F1_DOC   = D1_DOC     AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA"+Chr(13)
	cQuery += " WHERE C5.D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+cFilAnt+"' "
	
	if ! Empty(cNumPvDe)
		cQuery += " AND C5_NUM >= '"+cNumPvDe+"' "
	Endif

	if ! Empty(cNumPVAte)
		cQuery += " AND C5_NUM <= '"+cNumPvAte+"' "
	Endif

	if ! Empty(cEmiPvDe)
		cQuery += " AND C5_EMISSAO >= '"+cEmiPvDe+"' "
	Endif

	if ! Empty(cEmiPvAte)
		cQuery += " AND C5_EMISSAO <= '"+cEmiPvAte+"' "
	Endif

	// PEDIDO DE COMPRAS - CARREGA PROCESSO PARTINDO DOS PEDIDOS DE COMPRAS
	cQuery += Chr(13)+" UNION ALL "+Chr(13)

	cSelect := "SELECT DISTINCT C7_FILIAL AS FILIAL, "

	For nE := 1 to Len(aVetCpo)
		cCampo := aVetCpo[nE,2]
		if cCampo == "C1_PRODUTO"
			cCampo := "C7_PRODUTO AS PRODUTO"
		Elseif cCampo == "C1_FORNECE"
			cCampo := "C7_FORNECE AS FORNECE"
		Elseif cCampo == "C1_NUM"
			cCampo := "NVL(C1_NUM,' ') AS C1_NUM"
		Elseif cCampo == "F1_DOC"
			cCampo := "NVL(F1_DOC,' ') AS F1_DOC"
		Elseif cCampo == "D1_QUANT"
			cCampo := "NVL(D1_QUANT,0) AS D1_QUANT"
		Endif	
		cSelect += " "+cCampo+" , "
	Next

	cQuery += Left(cSelect,Len(cSelect)-3) +" "+Chr(13)
	cQuery += "  FROM "+RetSqlName("SC7")+" C7 " +Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC1")+" C1 ON C1.D_E_L_E_T_ <> '*' AND C1_FILIAL = C7_FILIAL AND C1_PEDIDO   = C7_NUM     AND C1_ITEMPED = C7_ITEM "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC6")+" C6 ON C6.D_E_L_E_T_ <> '*' AND C1_FILIAL = C6_FILIAL AND C1_NUM      = C6_NUMSC   AND C1_ITEM    = C6_ITEMSC "	+Chr(13)
	cQuery += "  LEFT JOIN (SELECT DISTINCT C5_FILIAL, C5_NUM, C5_NOTA, C5_SERIE, C5_EMISSAO FROM "+RetSqlName("SC5")+" WHERE D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+cFilAnt+"' ) C5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "	+Chr(13)"
	
	//Cesar 04/12/2024 - Ticket #24992 - RELATÓRIO DE FUP - NÚMERO DA OP
	//cQuery += "  LEFT JOIN "+RetSqlName("SC2")+" C2 ON C6.D_E_L_E_T_ <> '*' And C2_FILIAL = C6_FILIAL And C2_NUM   = C6_NUMOP      AND C2_ITEM    = C6_ITEMOP "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC2")+" C2 ON C2.D_E_L_E_T_ <> '*' And C2_FILIAL = C1_FILIAL And C2_NUM+C2_ITEM+C2_SEQUEN   = C1_OP "	+Chr(13)
	
	if Empty(cFilSB1)
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = ' ' And B1_COD   = C7_PRODUTO "	+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = C7_FILIAL And B1_COD   = C7_PRODUTO "	+Chr(13)
	Endif

	//	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" BM ON BM.D_E_L_E_T_ <> '*' And BM_FILIAL = '"+cFilSBM+"' And BM_GRUPO = B1_GRUPO "	+Chr(13)
	cQuery += "  LEFT JOIN (SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_EMINFE  FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_ <> '*' AND   F2_TIPO = 'N' ) F2 ON F2_FILIAL = C6_FILIAL AND F2_DOC   = C5_NOTA AND F2_SERIE = C5_SERIE " + Chr(13)
  	cQuery += "  LEFT JOIN "+RetSqlName("SD2")+" D2 ON D2.D_E_L_E_T_ <> '*' And D2_FILIAL = F2_FILIAL AND D2_DOC   = F2_DOC     AND D2_COD     = C6_PRODUTO "	+Chr(13)
	
	if Empty(cFilSA2)
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = ' '       AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = C6_FILIAL AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Endif
	
	cQuery += "  LEFT JOIN "+RetSqlName("SD1")+" D1 ON D1.D_E_L_E_T_ <> '*' And D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM    AND D1_ITEMPC  = C7_ITEM " + Chr(13)
	cQuery += "  LEFT JOIN (SELECT F1_FILIAL,  F1_DOC , F1_FORNECE, F1_LOJA, F1_EMISSAO ,  F1_DTDIGIT FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ <> '*'  AND F1_TIPO = 'N' ) F1 " + Chr(13)
	cQuery += "         ON F1_FILIAL = D1_FILIAL AND F1_DOC   = D1_DOC     AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA " + Chr(13)
 	cQuery += " WHERE C7.D_E_L_E_T_ <> '*' AND C7_FILIAL = '"+cFilAnt+"' "

	if ! Empty(cNumPcDe)
		cQuery += " AND C7_NUM >= '"+cNumPcDe+"' "
	Endif

	if ! Empty(cNumPcAte)
		cQuery += " AND C7_NUM <= '"+cNumPcAte+"' "
	Endif

	if ! Empty(cEmiPcDe)
		cQuery += " AND C7_EMISSAO >= '"+cEmiPcDe+"' "
	Endif

	if ! Empty(cEmiPcAte)
		cQuery += " AND C7_EMISSAO <= '"+cEmiPcAte+"' "
	Endif

	// SOLICITACOES - CARREGA PROCESSO PARTINDO DAS SOLICITACOES
	cQuery += Chr(13)+" UNION ALL "+Chr(13)

	cSelect := "SELECT DISTINCT C1_FILIAL AS FILIAL, "
	For nE := 1 to Len(aVetCpo)
		cCampo := aVetCpo[nE,2]
		if cCampo == "C1_PRODUTO"
			cCampo := "C1_PRODUTO AS PRODUTO"
		Elseif cCampo == "C1_FORNECE"
			cCampo := "C7_FORNECE AS FORNECE"
		Elseif cCampo == "C1_NUM"
			cCampo := "NVL(C1_NUM,' ') AS C1_NUM"
		Elseif cCampo == "F1_DOC"
			cCampo := "NVL(F1_DOC,' ') AS F1_DOC"
		Elseif cCampo == "D1_QUANT"
			cCampo := "NVL(D1_QUANT,0) AS D1_QUANT"
		Endif	
		cSelect += " "+cCampo+" , "
	Next

	cQuery += Left(cSelect,Len(cSelect)-3) +" "+Chr(13)
	cQuery += "  FROM "+RetSqlName("SC1")+" C1 " +Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC7")+" C7 ON C7.D_E_L_E_T_ <> '*' AND C7_FILIAL = C1_FILIAL AND C7_NUMSC = C1_NUM     AND C7_ITEMSC  = C1_ITEM    AND C7_PRODUTO = C1_PRODUTO "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC6")+" C6 ON C6.D_E_L_E_T_ <> '*' AND C1_FILIAL = C6_FILIAL AND C1_NUM      = C6_NUMSC   AND C1_ITEM    = C6_ITEMSC "	+Chr(13)
	cQuery += "  LEFT JOIN (SELECT DISTINCT C5_FILIAL, C5_NUM, C5_NOTA, C5_SERIE, C5_EMISSAO FROM "+RetSqlName("SC5")+" WHERE D_E_L_E_T_ <> '*' AND C5_FILIAL = '"+cFilAnt+"' ) C5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "	+Chr(13)"

	//Cesar 04/12/2024 - Ticket #24992 - RELATÓRIO DE FUP - NÚMERO DA OP
	//cQuery += "  LEFT JOIN "+RetSqlName("SC2")+" C2 ON C6.D_E_L_E_T_ <> '*' And C2_FILIAL = C6_FILIAL And C2_NUM   = C6_NUMOP   AND C2_ITEM    = C6_ITEMOP "	+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SC2")+" C2 ON C2.D_E_L_E_T_ <> '*' And C2_FILIAL = C1_FILIAL And C2_NUM+C2_ITEM+C2_SEQUEN   = C1_OP "	+Chr(13)
	
	if Empty(cFilSB1)
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = ' ' And B1_COD   = C1_PRODUTO "	+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ <> '*' And B1_FILIAL = C1_FILIAL And B1_COD   = C1_PRODUTO "	+Chr(13)
	Endif

	//	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" BM ON BM.D_E_L_E_T_ <> '*' And BM_FILIAL = '"+cFilSBM+"' And BM_GRUPO = B1_GRUPO "	+Chr(13)
	cQuery += "  LEFT JOIN (SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_EMINFE  FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_ <> '*' AND   F2_TIPO = 'N' ) F2 ON F2_FILIAL = C6_FILIAL AND F2_DOC   = C5_NOTA  AND F2_SERIE = C5_SERIE " + Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SD2")+" D2 ON D2.D_E_L_E_T_ <> '*' And D2_FILIAL = F2_FILIAL AND D2_DOC   = F2_DOC     AND D2_COD     = C6_PRODUTO "	+Chr(13)

	if Empty(cFilSA2)
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = ' '       AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Else
		cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2.D_E_L_E_T_ <> '*' And A2_FILIAL = C6_FILIAL AND A2_COD   = C7_FORNECE AND A2_LOJA    = C7_LOJA "		+Chr(13)
	Endif

	cQuery += "  LEFT JOIN "+RetSqlName("SD1")+" D1 ON D1.D_E_L_E_T_ <> '*' And D1_FILIAL = C6_FILIAL AND D1_NUMPV = C6_NUM     AND D1_ITEMPV  = C6_ITEM "		+Chr(13)
	cQuery += "  LEFT JOIN "+RetSqlName("SF1")+" F1 ON F1.D_E_L_E_T_ <> '*' And F1_FILIAL = D1_FILIAL AND F1_DOC   = D1_DOC     AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA"+Chr(13)
	cQuery += " WHERE C1.D_E_L_E_T_ <> '*' AND C1_FILIAL = '"+cFilAnt+"' "
	
	if ! Empty(cNumScDe)
		cQuery += " AND C1_NUM >= '"+cNumScDe+"' "
	Endif

	if ! Empty(cNumScAte)
		cQuery += " AND C1_NUM <= '"+cNumScAte+"' "
	Endif

	if ! Empty(cEmiScDe)
		cQuery += " AND C1_EMISSAO >= '"+cEmiScDe+"' "
	Endif

	if ! Empty(cEmiScAte)
		cQuery += " AND C1_EMISSAO <= '"+cEmiScAte+"' "
	Endif

	cQuery += " AND F1_DOC = ' '  "
	cQuery += ") TAB "
	cQuery += " WHERE "

	if cSolicit == '2'
		cQuery += " C1_NUM = ' ' AND "
	Elseif cSolicit == '1'
		cQuery += " C1_NUM <> ' ' AND "
	Endif

	if cResiduo == "2"
		cQuery += " (C7_QUANT - C7_QUJE) = 0  AND "
	Elseif cResiduo == "1"
		//cQuery += " (C7_QUANT - C7_QUJE) <> 0  AND " // Cesar 05/04/2024 Ticket #14855 - RELATÓRIO DE FOLLOW UP
		// cQuery += " (C7_QUANT - C7_QUJE) <> 0  AND (C7_RESIDUO ='' OR (C7_RESIDUO ='S' AND C7_QUJE <> 0)) AND "	// Cesar 05/04/2024 Ticket #14855 - RELATÓRIO DE FOLLOW UP

		// GUILHERME LEONEL - 17/07/2024
		// CHAMADO 17362
		// CLIENTE PEDIU PARA INCLUIR UM NOVO PARAMETRO SEPARADO PARA OS CASOS COM E SEM RESIDUO
		cQuery += " (C7_QUANT - C7_QUJE) <> 0  AND "
	Endif

	// GUILHERME LEONEL - 17/07/2024
	// CHAMADO 17362
	// CLIENTE PEDIU PARA INCLUIR UM NOVO PARAMETRO SEPARADO PARA OS CASOS COM E SEM RESIDUO
	IF cElimPc == "1"
		cQuery += " C7_RESIDUO = 'S' AND "
	ELSEIF cElimPc == "2"
		cQuery += " C7_RESIDUO = '' AND "
	ENDIF

	cQuery += " ( (  F1_DOC <> ' ' AND D1_QUANT  > 0)  OR  F1_DOC = ' ') "
	//cQuery += "ORDER BY FILIAL, C5_NUM, C6_ITEM, C7_NUM, C7_ITEM"

	cQuery := ChangeQuery(cQuery)

	// executa a query principal
	dbUseArea(.T. , "TopConn" , TcGenQry(,,cQuery) , "QRY" , .T. , .T.) 

	// executa o TcSetField conforme o dicionário
	For nE := 1 to Len(aVetCpo)
		aCpo := TamSx3(aVetCpo[nE,2])
		if aCpo[3] == "D" .or. aCpo[3] == "N"
			TcSetField( "QRY",aVetCpo[nE,2], aCpo[3], aCpo[1], aCpo[2] )
		Endif	
	Next

Return Nil


/*====================================================================================
Autor: 			Aldo Barbosa dos Santos
Data: 			20/04/2022
Consultoria: 	Prox
Uso: 			HLB
Info: 			Exibição do Help da rotina
*=====================================================================================*/
Static Function Versao(lAtiva)
	Local aHelpVer := {}
	Local _cHelp   := ""
	Local _nR
	Local _lHtml := .F.

	if lAtiva == Nil // exibicao do help
		Versao(.F.)  // desativa os atalhos do Help da rotina

		Aadd(aHelpVer,cTitRel+"  "+_cVersao+" "+_cDtVersao)
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,cDesRel)
		Aadd(aHelpVer,"")

		Aadd(aHelpVer,"  PROCESSAMENTO DO RELATÓRIO:")
		Aadd(aHelpVer,"    O processo ocorre em três frentes, sendo que cada frente tem seus filtros próprios.")
		Aadd(aHelpVer,"     - Primeira frente - Pedido de Venda: Partindo dos pedidos de venda e tentando localizar as demais informações")
		Aadd(aHelpVer,"     - Segunda frente - Pedido de Compras: Partindo dos pedidos de compra e tentando localizar as demais informações")
		Aadd(aHelpVer,"     - Terceira frente - Solicitação de Compras: Partindo das solicitações de compra e tentando localizar as demais informações.")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"  PARAMETROS DO RELATÓRIO:")
		Aadd(aHelpVer,"    Parâmetros Pedido de Venda:")
		Aadd(aHelpVer,"    	- Pedido Venda De/Até: Informar o número do pedido inicial e final para o filtro.")
		Aadd(aHelpVer,"    	- Dt.Ped.Venda De/Até: Informar a data de emissão inicial para os pedidos de venda")
		Aadd(aHelpVer,"    	Parâmetros Pedido de Compras:")
		Aadd(aHelpVer,"    	- Pedido Compra De/Até : Informar o número do pedido inicial e final para o filtro")
		Aadd(aHelpVer,"    	- Dt.Ped. Compra De/Até: Informar a data de emissão inicial e final para os pedidos de compras")
		Aadd(aHelpVer,"    	Parâmetros Solicitação de Compras:")
		Aadd(aHelpVer,"    	- Solicitação Compra De/Até: Informar o número da solicitação inicial e final para o filtro")
		Aadd(aHelpVer,"    	- Dt. Solicitação De/Até   : Informar a data de emissão inicial e final para as solicitações")
		Aadd(aHelpVer,"    	Parâmetros Genéricos:")
		Aadd(aHelpVer,"    	- Com Resíduo		: 1=Sim;2=Não;3=Todos")
		Aadd(aHelpVer,"    	- Com Solicitação	: 1=Sim;2=Não;3=Todos")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"Ajustes realizados:")
		Aadd(aHelpVer,"08-07-2022 Incluida a coluna 'MOEDA' - v2.07")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"03-06-2022 Eliminação de linhas duplicadas e inclusão da coluna 'Item da Solicitação'- v2.06")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"30-05-2022 Incluida a coluna Observação da Solicitação - v2.05")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"30-05-2022 Incluida a coluna Grupo do produto - v2.04")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"27-05-2022 Processamento em 3 frentes - v2.03")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"23-05-2022 Atualização da rotina de processamento .")
		Aadd(aHelpVer,"  Neste momento foi ajustado para iniciar pelo Pedido de Compras e seguir os dados que existirem na base de dados. Foi explanado que os dados atuais não permitem emitir o relatório completo.")
		Aadd(aHelpVer,"")
		Aadd(aHelpVer,"")

		// coloca as quebras de linha e os espacos no formato HTML ou Texto
		For _nR := 1 to Len(aHelpVer)
			if _lHtml
				_cVarTxt := Strtran(Strtran(Strtran(aHelpVer[_nR],"   ","&nbsp;&nbsp;&nbsp;"),"  ","&nbsp;&nbsp;")," ","&nbsp;")
				_cHelp += "<BR>"+_cVarTxt
			Else
				_cVarTxt := Strtran(StrTran(aHelpVer[_nR],"<B>",""),"</B>","")
				_cHelp   += Chr(13)+Chr(10)+_cVarTxt
			Endif	
		Next

		DEFINE MSDIALOG oDlgHlp TITLE "Help da Rotina "+cFtnPad FROM C(264),C(469) TO C(676),C(1010) PIXEL

			// Cria Componentes Padroes do Sistema
			@ C(002),C(002) GET oMemo1 Var _cHelp MEMO When .F. Size C(266),C(186) PIXEL OF oDlgHlp
			@ C(191),C(230) Button "Ok" Size C(037),C(012) Action (oDlgHlp:End()) PIXEL OF oDlgHlp
			
		ACTIVATE MSDIALOG oDlgHlp CENTERED 

		Versao(.T.) // ativa os atalhos do Help da rotina

	Elseif lAtiva 
		//Ativo os atalhos do Help da rotina
		SetKey(K_CTRL_F1, {|| Versao() })
		SetKey(K_ALT_F1 , {|| Versao() })
		SetKey(K_SH_F1  , {|| Versao() })

	Elseif ! lAtiva
		//Ativo os atalhos do Help da rotina
		SetKey(K_CTRL_F1, Nil )
		SetKey(K_ALT_F1 , Nil )
		SetKey(K_SH_F1  , Nil )
	Endif
Return

