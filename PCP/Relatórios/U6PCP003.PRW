#include "protheus.ch"
#Include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ IOPEXCL  ¦ Autor ¦  Fábrica ERP.BR   ¦ Data ¦  Nov/2024    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Chamada exclusiva para impressão da ordem de produção      ¦¦¦
¦¦¦          ¦ modelo específico Pdf.							  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function IOPEXCL(lOpen)

Local aOrdPrd := {}
Local aOrdTmp := {}
Local cPath   := "c:\report"
Local lExibe  := IIf(lOpen==Nil,.T.,lOpen)
Local lPedido := .F.
Local _op

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa não autorizada: "+FWCodEmp())
	Return
Endif

If !MsgYesNo("Deseja imprimir o Pick-List de separação para a Ordem de Produção "+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+" ?","Aviso")
	Return
Endif

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

cProdVn := SC2->C2_PRODUTO
If SC2->C2_SEQUEN <> "001"
	nRecSc2 := SC2->(Recno())
	DbSelectArea("SC2")
	DbSetOrder(1)
	If DbSeek( xFilial("SC2") + SC2->C2_NUM + SC2->C2_ITEM + "001" )
		cProdVn := SC2->C2_PRODUTO
	Endif
	SC2->(DbGoto(nRecSc2))
Endif	

cQuery := " SELECT DISTINCT C6_NUM, C6_CLI, C6_LOJA "
cQuery += " FROM "+RetSqlName("SC6")
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND C6_PRODUTO = '"+cProdVn+"' "
cQuery += " AND C6_QTDVEN > C6_QTDENT "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C6_NUM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL6", .F., .T.)

DbSelectArea("SQL6")
SQL6->(DbGotop())
While !Eof()

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xFilial("SC5") + SQL6->C6_NUM )

	If SC5->(FieldPos("C5_XSEIBAN")) > 0
		If SC2->(FieldPos("C2_XSEIBAN")) > 0
			If AllTrim(SC5->C5_XSEIBAN) == AllTrim(SC2->C2_XSEIBAN)
				lPedido := .T.
			Endif
		Else
			lPedido := .T.
		Endif
	Else
		lPedido := .T.
	Endif

	If lPedido
		Exit
	Endif

	DbSelectArea("SQL6")
	SQL6->(DbSkip())
Enddo
SQL6->(DbCloseArea())
If !lPedido
	MsgAlert("Pedido de Venda não localizado para a Ordem de Produção.")
	Return
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SD4")
cQuery += " WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery += " AND SUBSTRING(D4_OP,1,8) = '"+SC2->(C2_NUM+C2_ITEM)+"' "
If SC2->C2_SEQUEN == "001"
	cQuery += " AND D4_OP >= '"+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+"' "
Else
	cQuery += " AND D4_OP = '"+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+"' "
Endif	
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY D4_FILIAL, D4_OP, D4_COD "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL4", .F., .T.)

DbSelectArea("SQL4")
SQL4->(DbGotop())
While !Eof()

	If Substr(SQL4->D4_COD,1,3) == "MOD"
		DbSelectArea("SQL4")
		SQL4->(DbSkip())
		Loop		
	Endif

	DbSelectArea("SG1")
	DbSetOrder(1)
	If DbSeek( xFilial("SG1") + SQL4->D4_COD )
		DbSelectArea("SQL4")
		SQL4->(DbSkip())
		Loop		
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + SQL4->D4_COD )
	If SB1->B1_ZZGRP2 $("SHM,RNR")
		DbSelectArea("SQL4")
		SQL4->(DbSkip())
		Loop		
	Endif

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SQL4->D4_COD + SQL4->D4_LOCAL )

	cQuery := " SELECT D1_FORNECE, D1_LOJA "
	cQuery += " FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
	cQuery += " AND D1_COD = '"+SQL4->D4_COD+"' "
	cQuery += " AND D1_TIPO = 'N' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY D1_DTDIGIT DESC "
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL1", .F., .T.)

	cFornec := "FORNECEDOR COMPRA"
	DbSelectArea("SQL1")
	SQL1->(DbGotop())
	If !Eof()
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SQL1->D1_FORNECE + SQL1->D1_LOJA )
		cFornec := Substr(SA2->A2_NOME,1,20)
	Endif
	SQL1->(DbCloseArea())

	cComplem := Posicione("SB1",1,xFilial("SB1")+SQL4->D4_COD,"B1_DESCR01")
	If Empty(cComplem)
		cComplem := Posicione("SB1",1,xFilial("SB1")+SQL4->D4_COD,"B1_DESC")
	Endif

	cEndere := ""
	DbSelectArea("SDC")
	DbSetOrder(2)
	If DbSeek( xFilial("SDC") + SQL4->D4_COD + SQL4->D4_LOCAL +SQL4->D4_OP )
		While !Eof() .And. SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP) == xFilial("SDC") + SQL4->D4_COD + SQL4->D4_LOCAL +SQL4->D4_OP

			// Estrutura:
			// [1]  - Cliente
			// [2]  - Ordem Produção
			// [3]  - Quantidade
			// [4]  - Código Produto
			// [5]  - Descrição Produto
			// [6]  - Previsão Início
			// [7]  - Data Entrega
			// [8]  - Seiban
			// [9]  - Código Componente
			// [10] - Descrição Componente
			// [11] - Quantidade requerida
			// [12] - Quantidade disponível
			// [13] - Descrição complementar
			// [14] - Fornecedor
			// [15] - Endereço

			AAdd(aOrdTmp,{ Substr(SA1->A1_NOME,1,40),;
						SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),;
						SC2->C2_QUANT,;
						SC2->C2_PRODUTO,;
						Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"),;
						SC2->C2_DATPRI,;
						SC2->C2_DATPRF,;
						IIf( SC2->(FieldPos("C2_XSEIBAN")) > 0, SC2->C2_XSEIBAN, "#SEIBAN" ),;
						SQL4->D4_COD,;
						Posicione("SB1",1,xFilial("SB1")+SQL4->D4_COD,"B1_DESC"),;
						SQL4->D4_QUANT,;
						SB2->B2_QATU,;
						cComplem,;
						cFornec,;
						SDC->DC_LOCALIZ })

			DbSelectArea("SDC")
			SDC->(DbSkip())
		Enddo
	Else

		// Estrutura:
		// [1]  - Cliente
		// [2]  - Ordem Produção
		// [3]  - Quantidade
		// [4]  - Código Produto
		// [5]  - Descrição Produto
		// [6]  - Previsão Início
		// [7]  - Data Entrega
		// [8]  - Seiban
		// [9]  - Código Componente
		// [10] - Descrição Componente
		// [11] - Quantidade requerida
		// [12] - Quantidade disponível
		// [13] - Descrição complementar
		// [14] - Fornecedor
		// [15] - Endereço

		AAdd(aOrdTmp,{ Substr(SA1->A1_NOME,1,40),;
					SQL4->D4_OP,;
					SC2->C2_QUANT,;
					SC2->C2_PRODUTO,;
					Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"),;
					SC2->C2_DATPRI,;
					SC2->C2_DATPRF,;
					IIf( SC2->(FieldPos("C2_XSEIBAN")) > 0, SC2->C2_XSEIBAN, "#SEIBAN" ),;
					SQL4->D4_COD,;
					Posicione("SB1",1,xFilial("SB1")+SQL4->D4_COD,"B1_DESC"),;
					SQL4->D4_QUANT,;
					SB2->B2_QATU,;
					cComplem,;
					cFornec,;
					"" })

	Endif

	DbSelectArea("SQL4")
	SQL4->(DbSkip())
Enddo
SQL4->(DbCloseArea())

If Len(aOrdTmp) > 0

	// Ordena por Endereço + Produto
	aSort(aOrdTmp,,, { |x, y| x[15]+x[4] < y[15]+y[4] } ) 

	// Adiciona os itens com Endereço
	For _op := 1 to Len(aOrdTmp)
		If !Empty( aOrdTmp[_op][15] )
			nPos := aScan(aOrdPrd, {|x| x[9] == aOrdTmp[_op][9] .And. x[15] == aOrdTmp[_op][15]}) // Código Componente + Endereço
			If nPos == 0
				AAdd(aOrdPrd,{ aOrdTmp[_op][1], aOrdTmp[_op][2], aOrdTmp[_op][3], aOrdTmp[_op][4], aOrdTmp[_op][5], aOrdTmp[_op][6], aOrdTmp[_op][7], aOrdTmp[_op][8],;
								aOrdTmp[_op][9], aOrdTmp[_op][10], aOrdTmp[_op][11], aOrdTmp[_op][12], aOrdTmp[_op][13], aOrdTmp[_op][14], aOrdTmp[_op][15] })
			Else
				aOrdPrd[nPos][11] += aOrdTmp[_op][11] // Quantidade requerida
			Endif
		Endif
	Next _op

	// Adiciona os itens sem Endereço
	For _op := 1 to Len(aOrdTmp)
		If Empty( aOrdTmp[_op][15] )
			nPos := aScan(aOrdPrd, {|x| x[9] == aOrdTmp[_op][9]}) // Código Componente
			If nPos == 0
				AAdd(aOrdPrd,{ aOrdTmp[_op][1], aOrdTmp[_op][2], aOrdTmp[_op][3], aOrdTmp[_op][4], aOrdTmp[_op][5], aOrdTmp[_op][6], aOrdTmp[_op][7], aOrdTmp[_op][8],;
								aOrdTmp[_op][9], aOrdTmp[_op][10], aOrdTmp[_op][11], aOrdTmp[_op][12], aOrdTmp[_op][13], aOrdTmp[_op][14], aOrdTmp[_op][15] })
			Else
				aOrdPrd[nPos][11] += aOrdTmp[_op][11] // Quantidade requerida
			Endif
		Endif
	Next _op

	FwMsgRun(, { || U_PDFORDP(aOrdPrd, cPath, lExibe) },,"Emitindo pick-list de separação")

Else
	MsgAlert("Ordem de Produção não disponível para impressão.")
Endif

Return
