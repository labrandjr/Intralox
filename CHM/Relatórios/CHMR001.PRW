#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ CHMR001  ¦ Autor ¦ Fábrica ERPBR	¦ Data  ¦ 29/05/2020      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Relatório de registro de chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHMR001()

Local cPerg     := "CHMR01"
Local cUsrConst := AllTrim(GetMv("MV_ZUSRPRT"))
Local lAcesso   := .F.
Private cPath   := "c:\report\"

If (__cUserId == "000000") .Or. (__cUserId $(cUsrConst)) 
	lAcesso := .T.
Endif

If !lAcesso
	MsgAlert("Usuário não autorizado.")
	Return
Endif

If Pergunte(cPerg,.T.)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	If MsgYesNo("Confirma processamento ?","Aviso","INFO")
		Processa({|| pChmR01()})
	Endif	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ pChmR01   ¦ Autor ¦ Fábrica ERPBR ¦ Data  ¦ 29/05/2020     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Processamento principal.							  	  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AMINOAGRO 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pChmR01()

Local oExcel := FwMsExcel():New()
Local cQuery

ProcRegua(2)

IncProc("Selecionando registros...")
cQuery := " SELECT COUNT(*) AS SOMA "
cQuery += " FROM "+RetSqlName("ZC1")
cQuery += " WHERE ZC1_FILIAL = '"+xFilial("ZC1")+"' "
cQuery += " AND ZC1_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)
nTotSql := SQL->SOMA
SQL->(DbCloseArea())

IncProc("Selecionando registros...")
cQuery := " SELECT R_E_C_N_O_ RECZC1 "
cQuery += " FROM "+RetSqlName("ZC1")
cQuery += " WHERE ZC1_FILIAL = '"+xFilial("ZC1")+"' "
cQuery += " AND ZC1_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY ZC1_FILIAL, ZC1_NUM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(nTotSql)
SQL->(DbGotop())
If !Eof()

	cNomePlan  := "ZC1_CHMR01"
	cNomeTable := "Registro de Chamados - "+DtoC(mv_par01)+" a "+DtoC(mv_par02)
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable(cNomePlan,cNomeTable)

	oExcel:AddColumn(cNomePlan,cNomeTable,"Chamado",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Título",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Data",1,4)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Hora",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Usuário",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Depto.",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Criticidade",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Classe",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Status",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Em cópia",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Interações",1,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"SLA",3,1)
	oExcel:AddColumn(cNomePlan,cNomeTable,"Horas",3,1)

	While !Eof()

		IncProc("Gerando planilha...")

		DbSelectArea("ZC1")
		DbSetOrder(1)
		ZC1->(DbGoto(SQL->RECZC1))
		
		zStatus := ""
		If ZC1->ZC1_STATUS == "A"
			zStatus := "Em aberto"
		ElseIf ZC1->ZC1_STATUS == "S"
			zStatus := "Pendente solicitante"
		ElseIf ZC1->ZC1_STATUS == "C"
			zStatus := "Pendente consultor"
		ElseIf ZC1->ZC1_STATUS == "E"
			zStatus := "Encerrado"
		Endif

		zCopia  := ""
		DbSelectArea("ZC2")
		DbSetOrder(1)
		DbSeek( xFilial("ZC2") + ZC1->ZC1_NUM )
		While !Eof() .And. ZC2->(ZC2_FILIAL+ZC2_NUM) == xFilial("ZC2") + ZC1->ZC1_NUM
			zCopia += IIf(!Empty(zCopia), " || ", "") + AllTrim(ZC2->ZC2_NOMUSU)
			ZC2->(DbSkip())
		Enddo
		
		zIntera := ""
		DbSelectArea("ZC3")
		DbSetOrder(1)
		DbSeek( xFilial("ZC3") + ZC1->ZC1_NUM )
		While !Eof() .And. ZC3->(ZC3_FILIAL+ZC3_NUM) == xFilial("ZC3") + ZC1->ZC1_NUM
			If !Empty(zIntera)
				zIntera += CHR(13)+CHR(10)
			Endif
			zIntera += AllTrim(ZC3->ZC3_NOMUSU)+" | Data: "+DtoC(ZC3->ZC3_DATA)+" | Hora: "+AllTrim(ZC3->ZC3_HORA)+" | "
			zIntera += AllTrim(ZC3->ZC3_DESCRI)+" || "
			ZC3->(DbSkip())
		Enddo

		zSla := Transform(ZC1->ZC1_SLA,"@R 99:99")	
		zHrs := Transform(ZC1->ZC1_HRS,"@R 99:99")	

		oExcel:AddRow(cNomePlan, cNomeTable, {ZC1->ZC1_NUM, ZC1->ZC1_TITULO, ZC1->ZC1_DATA, ZC1->ZC1_HORA, ZC1->ZC1_NOMUSU, ZC1->ZC1_DEPTO,;
					  						  ZC1->ZC1_CRITIC, ZC1->ZC1_CLASSE, AllTrim(ZC1->ZC1_DESCRI), zStatus, zCopia, zIntera, zSla, zHrs })

		DbSelectArea("SQL")
		SQL->(DbSkip())
		
	Enddo

	IncProc("Exportando Informações para Excel")
	
	oExcel:Activate()
	cFile := "ZC1_CHMR01-"+StrTran(DtoC(Date()),"/","-",1)+"_"+StrTran(Time(),":","-",1)+".xml"
	oExcel:GetXmlFile(cFile)
	
	CpyS2t("\system\"+cFile, AllTrim(cPath))

	ShellExecute( "Open", cPath+cFile, cFile, cPath, 3 )
	MsgInfo(cFile + " Ok !!")
	fErase(cFile)

Else

	MsgInfo("Sem dados para geração do arquivo. Verifique os parâmetros.")

Endif
SQL->(DbCloseArea())
	
Return
