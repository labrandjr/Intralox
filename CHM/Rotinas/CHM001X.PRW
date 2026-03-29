#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001X   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interface do processo de chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001X(lCabec,lCopia,lInter,lVisua)

Local aArea := GetArea()

Local aObjects := {}
Local aSizeAut := {}
Local aInfo    := {}
Local aPosObj  := {}

Private nOpcChm := 0
Private oDlgChm := Nil
Private bActOk  := {|| nOpcChm:=1,oDlgChm:End() }
Private bActCan := {|| nOpcChm:=0,oDlgChm:End() }
Private bOkChm  := {|| IIf(lVisua, Eval(bActCan), IIf(MsgYesNo("Confirma gravação do chamado?","Registrar"), Eval(bActOk) , .F.)) }
Private bCanChm := {|| IIf(lVisua, Eval(bActCan), IIf(MsgYesNo("Abandona gravação do chamado?","Sair")     , Eval(bActCan), .F.)) }

// Colunas do browse1 - Usuários em cópia
Private nFd1Leg := 1
Private nFd1Cod := 2
Private nFd1Usu := 3
Private nFd1Eml := 4

// Colunas do browse2 - Interação
Private nFd2Leg := 1
Private nFd2Cod := 2
Private nFd2Usu := 3
Private nFd2Dat := 4
Private nFd2Hor := 5
Private nFd2Des := 6

Private cDBType	:= Alltrim(Upper(TCGetDB()))
Private lSQL	:= !(cDBType $"ORACLE|POSTGRES|DB2|INFORMIX")

Private oLbxCop := Nil
Private aVetCop := {}
Private oLbxInt := Nil
Private aVetInt := {}

Private oVerde  := LoadBitmap( GetResources(), "ENABLE" )
Private oVerme  := LoadBitmap( GetResources(), "DISABLE" )
Private oViolet := LoadBitmap( GetResources(), "BR_VIOLETA" )
Private oAzul   := LoadBitmap( GetResources(), "BR_AZUL" )
Private oAmare  := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oMarrom := LoadBitmap( GetResources(), "BR_MARROM" )
Private oCinza  := LoadBitmap( GetResources(), "BR_CINZA" )
Private oPink   := LoadBitmap( GetResources(), "BR_PINK" )
Private oPreto  := LoadBitmap( GetResources(), "BR_PRETO" )
Private oLaranj := LoadBitmap( GetResources(), "BR_LARANJA" )
Private oTAmare := LoadBitmap( GetResources(), "PMSEDT2" )
Private oTVerde := LoadBitmap( GetResources(), "PMSEDT3" )
Private oTCinza := LoadBitmap( GetResources(), "PMSEDT4" )
Private oBranco := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oVerEsc := LoadBitmap( GetResources(), "BR_VERDE_ESCURO" )
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private cEOL      := CHR(13)+CHR(10) 
Private cCadastro := "Registro de Chamados"
Private bWhenComb := {|u| lCabec}
Private bWhenClas := {|u| IIf(lConsult,.T.,lCabec) }

Private cChamado := ""
Private cTitCham := ""
Private dDataChm := Date()
Private cHoraChm := Substr(Time(),1,5)
Private cCodUsu  := __cUserId
Private cNomUsu  := cUserName
Private cEmlUsu  := UsrRetMail(__cUserId)
Private cDepto   := ""
Private aDepto   := {"","Compras","Comercial","Cobrança","Controladoria","Custos","Estoque","Faturamento","Financeiro","Fiscal","Logística","Manutenção","Marketing","Produção","RH","TI-Infra"}
Private cCriti   := ""
Private aCriti   := {"","Baixa","Média","Alta"}
Private cClass   := ""
Private aClass   := {"","Dúvida","Análise","Problema","Solicitação"}
Private cDescri  := ""
Private lConsult := ( __cUserId $(cUsrConst) )

If lCabec
	cNovoChm := GetSxeNum("ZC1","ZC1_NUM")
	ConfirmSx8()
	cChamado := cNovoChm 
	cTitCham := Space(100)
	dDataChm := Date()
	cHoraChm := Substr(Time(),1,5)
	cCodUsu  := __cUserId
	cNomUsu  := cUserName
	cEmlUsu  := UsrRetMail(__cUserId)
Else
	cChamado := ZC1->ZC1_NUM
	cTitCham := ZC1->ZC1_TITULO
	dDataChm := ZC1->ZC1_DATA
	cHoraChm := ZC1->ZC1_HORA
	cCodUsu  := ZC1->ZC1_CODUSU
	cNomUsu  := ZC1->ZC1_NOMUSU
	cEmlUsu  := ZC1->ZC1_EMLUSU
	cDepto   := ZC1->ZC1_DEPTO
	cCriti   := ZC1->ZC1_CRITIC
	cClass   := ZC1->ZC1_CLASSE
	cDescri  := ZC1->ZC1_DESCRI
Endif

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.T.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

aSizeAut := MsAdvSize(,.F.,400)

aObjects := {}  
AAdd( aObjects, { 000, 030, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

oDlgChm := MsDialog():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,,,,,.T.)

// Dimensionamento do Dlg
nLaDlg := aSizeAut[5] // 1474
nAlDlg := aSizeAut[6] // 659

// Fator Altura do Dlg
//nFtAlt := (200/659)
nFtAlt := (50/659)
nAlBr4 := Round((nFtAlt * nAlDlg),0) // Linha final (Browse Redimensionado)

// Fator Largura do Dlg
nFtLar := (730/1474)
nLaBr3 := Round((nFtLar * nLaDlg),0) // Coluna final (Browse Redimensionado)

// *************************************************************** //
// ** Cabeçalho                                                 ** //
// *************************************************************** //

// Coluna 1
nLin1 := 040
@ nLin1,005 SAY "No.Chamado" OF oDlgChm PIXEL SIZE 055,009
@ nLin1-1,040 TO nLin1+11,090 LABEL "" OF oDlgChm PIXEL
oSayNum:= TSay():New(nLin1+2,050,{|| cChamado },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayNum:CtrlRefresh()

@ nLin1,100 SAY "Título" OF oDlgChm PIXEL SIZE 055,009
@ nLin1-1,120 MSGET oTitCham VAR cTitCham SIZE 220,010 OF oDlgChm PIXEL PICTURE "@!" WHEN lCabec

@ nLin1,360 SAY "Data" OF oDlgChm PIXEL SIZE 055,009
@ nLin1-1,380 TO nLin1+11,430 LABEL "" OF oDlgChm PIXEL
oSayDat:= TSay():New(nLin1+2,387,{|| dDataChm },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayDat:CtrlRefresh()

@ nLin1,450 SAY "Hora" OF oDlgChm PIXEL SIZE 055,009
@ nLin1-1,470 TO nLin1+11,520 LABEL "" OF oDlgChm PIXEL
oSayHor:= TSay():New(nLin1+2,485,{|| cHoraChm },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayHor:CtrlRefresh()

@ nLin1+15,005 SAY "Usuário" OF oDlgChm PIXEL SIZE 055,009
@ nLin1+14,040 TO nLin1+26,090 LABEL "" OF oDlgChm PIXEL
oSayCod:= TSay():New(nLin1+17,050,{|| cCodUsu },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayCod:CtrlRefresh()

@ nLin1+14,095 TO nLin1+26,190 LABEL "" OF oDlgChm PIXEL
oSayNom:= TSay():New(nLin1+17,120,{|| cNomUsu },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayNom:CtrlRefresh()

@ nLin1+14,195 TO nLin1+26,340 LABEL "" OF oDlgChm PIXEL
oSayEml:= TSay():New(nLin1+17,205,{|| cEmlUsu },oDlgChm,,oFnt3,,,,.T.,,,200,020)
oSayEml:CtrlRefresh()

@ nLin1+30,005 SAY "Classe" OF oDlgChm PIXEL SIZE 100,009
oComboL := TComboBox():New(nLin1+29,040,{|u| If(PCount()>0,cClass:=u,cClass)},aClass,070,013,oDlgChm,,,,,,.T.,,,,bWhenClas,,,,,"cClass")

@ nLin1+30,130 SAY "Criticidade" OF oDlgChm PIXEL SIZE 100,009
oComboR := TComboBox():New(nLin1+29,160,{|u| If(PCount()>0,cCriti:=u,cCriti)},aCriti,070,013,oDlgChm,,,,,,.T.,,,,bWhenComb,,,,,"cCriti")

@ nLin1+30,250 SAY "Depto." OF oDlgChm PIXEL SIZE 100,009
oComboD := TComboBox():New(nLin1+29,270,{|u| If(PCount()>0,cDepto:=u,cDepto)},aDepto,070,013,oDlgChm,,,,,,.T.,,,,bWhenComb,,,,,"cDepto")

@ nLin1+45,005 SAY "Descrição" OF oDlgChm PIXEL SIZE 100,009
oDescri := TMultiget():New(nLin1+55,005,{|u| If(PCount()>0,cDescri:=u,cDescri)},oDlgChm,520,050,,,,,,.T.,,,bWhenComb)

oSayLb1:= TSay():New(nLin1+110,005,{|| "USUÁRIOS EM CÓPIA" },oDlgChm,,oFnt3,,,,.T.,,,200,020) // 150
// ***************************************************************************************************** //
// ** Browse1 - Usuários em cópia			                                                          ** //
// ***************************************************************************************************** //
n1Brw1 := nLin1+120 // 160
n1Brw2 := 005
n1Brw3 := nLaBr3
n1Brw4 := 060

fCarga1(lCabec,lCopia,lInter,lVisua,@aVetCop)

oLbxCop := TWBrowse():New(n1Brw1,n1Brw2,n1Brw3,n1Brw4,,,,oDlgChm,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxCop:AddColumn( TcColumn():New( "  "    	 ,{ || IIf(Len(aVetCop)==0,oVerme,IIf(aVetCop[oLbxCop:nAt][nFd1Leg],oVerde,oVerme))} , "@!" ,,,"CENTER",010,.T.,.F.,,,,.F.,) )
oLbxCop:AddColumn( TcColumn():New( "Id"      ,{ || aVetCop[oLbxCop:nAt][nFd1Cod] } , "@!" ,,,"LEFT"	 ,030,.F.,.F.,,,,.F.,) )
oLbxCop:AddColumn( TcColumn():New( "Usuário" ,{ || aVetCop[oLbxCop:nAt][nFd1Usu] } , "@X" ,,,"LEFT"	 ,060,.F.,.F.,,,,.F.,) )
oLbxCop:AddColumn( TcColumn():New( "E-mail"  ,{ || aVetCop[oLbxCop:nAt][nFd1Eml] } , "@X" ,,,"LEFT"	 ,100,.F.,.F.,,,,.F.,) )

oLbxCop:SetArray(aVetCop)
oLbxCop:bHeaderClick := { |o,x,y| fHeader1( o , x , y , @oLbxCop , @aVetCop ) }
oLbxCop:bLDblClick := { || fClick1(@oLbxCop,@aVetCop,oLbxCop:nAt,oLbxCop:nColPos,lCabec,lCopia,lInter,lVisua) }

oSayLb2:= TSay():New(nLin1+190,005,{|| "INTERAÇÕES" },oDlgChm,,oFnt3,,,,.T.,,,200,020) // 230
// ***************************************************************************************************** //
// ** Browse2 - Interações no chamado		                                                          ** //
// ***************************************************************************************************** //
n2Brw1 := nLin1+200 // 240
n2Brw2 := 005
n2Brw3 := nLaBr3
n2Brw4 := 200//nAlBr4

fCarga2(lCabec,lCopia,lInter,lVisua,@aVetInt)

oLbxInt := TWBrowse():New(n2Brw1,n2Brw2,n2Brw3,n2Brw4,,,,oDlgChm,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxInt:AddColumn( TcColumn():New( "  "    	   ,{ || IIf(Len(aVetInt)==0,oVerme,IIf(aVetInt[oLbxInt:nAt][nFd2Leg],oVerde,oVerme))} , "@!" ,,,"CENTER",010,.T.,.F.,,,,.F.,) )
oLbxInt:AddColumn( TcColumn():New( "Id"        ,{ || aVetInt[oLbxInt:nAt][nFd2Cod] } , "@!" ,,,"LEFT"	 ,030,.F.,.F.,,,,.F.,) )
oLbxInt:AddColumn( TcColumn():New( "Usuário"   ,{ || aVetInt[oLbxInt:nAt][nFd2Usu] } , "@X" ,,,"LEFT"	 ,060,.F.,.F.,,,,.F.,) )
oLbxInt:AddColumn( TcColumn():New( "Data"      ,{ || aVetInt[oLbxInt:nAt][nFd2Dat] } , "@!" ,,,"LEFT"	 ,060,.F.,.F.,,,,.F.,) )
oLbxInt:AddColumn( TcColumn():New( "Hora"      ,{ || aVetInt[oLbxInt:nAt][nFd2Hor] } , "@!" ,,,"CENTER"	 ,060,.F.,.F.,,,,.F.,) )
oLbxInt:AddColumn( TcColumn():New( "Descrição" ,{ || aVetInt[oLbxInt:nAt][nFd2Des] } , "@!" ,,,"LEFT"	 ,200,.F.,.F.,,,,.F.,) )

oLbxInt:SetArray(aVetInt)
oLbxInt:bHeaderClick := { |o,x,y| fHeader2( o , x , y , @oLbxInt , @aVetInt ) }
oLbxInt:bLDblClick := { || fClick2(@oLbxInt,@aVetInt,oLbxInt:nAt,oLbxInt:nColPos,lCabec,lCopia,lInter,lVisua) }

If lCopia
	oLbxCop:SetFocus()
	oLbxInt:Disable()
ElseIf lInter
	oLbxInt:SetFocus()
	oLbxCop:Disable()
Endif

oDlgChm:Activate(,,,.T.,{|| _Validar(lCabec,lCopia,lInter,lVisua,aVetCop,aVetInt) },,{|| EnchoiceBar(oDlgChm,bOkChm,bCanChm) } )

If nOpcChm == 1
	MsgRun("Gravando informações... aguarde","Processando",{|| _GravaInf(lCabec,lCopia,lInter,lVisua,aVetCop,aVetInt) })
Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader1 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  25/04/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeader1(oObj,nCol,nLin,oLbxCop,aVetCop)

oLbxCop:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClick1   ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  25/04/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClick1(oLbxCop,aVetCop,nLin,nCol,lCabec,lCopia,lInter,lVisua)

If Len(aVetCop) == 0
	Return
Endif

If lCopia .And. aVetCop[nLin][nFd1Leg] 
	If nCol == nFd1Cod // Código do usuário
		If ConPad1(,,,"USR",,,.F./*lOnlyView*/,/*Campo chamada*/,,aVetCop[nLin][nCol]/*Cont.Campo Antes Chamada*/)
			aVetCop[nLin][nFd1Cod] := aCpoRet[1]
			aVetCop[nLin][nFd1Usu] := UsrRetName(aCpoRet[1])
			aVetCop[nLin][nFd1Eml] := UsrRetMail(aCpoRet[1])
		Else
			aVetCop[nLin][nFd1Cod] := Space(6)
			aVetCop[nLin][nFd1Usu] := Space(15)
			aVetCop[nLin][nFd1Eml] := Space(100)
		Endif
	Endif
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga1  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  25/04/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtra dados para browse1 - usuários em cópia.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga1(lCabec,lCopia,lInter,lVisua,aVetCop)

Local _x

If lCabec
	For _x := 1 to 4
		AAdd(aVetCop,{.T., Space(6), Space(15), Space(100) })
	Next _x	
Else 
	DbSelectArea("ZC2")
	DbSetOrder(1)
	DbSeek( xFilial("ZC2") + ZC1->ZC1_NUM )
	While !Eof() .And. ZC2->(ZC2_FILIAL+ZC2_NUM) == xFilial("ZC2") + ZC1->ZC1_NUM
		AAdd(aVetCop,{.F., ZC2->ZC2_CODUSU, ZC2->ZC2_NOMUSU, ZC2->ZC2_EMLUSU })
		ZC2->(DbSkip())
	Enddo
Endif

If lCopia
	AAdd(aVetCop,{.T., Space(6), Space(15), Space(100) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fHeader2 ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  25/04/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ações para o cabeçalho das colunas do Folder.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fHeader2(oObj,nCol,nLin,oLbxInt,aVetInt)

oLbxInt:Refresh()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fClick2   ¦ Autor ¦  Fabrica ERPBR ¦  Data ¦  25/04/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ação de duplo-clique nas colunas do browse.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fClick2(oLbxInt,aVetInt,nLin,nCol,lCabec,lCopia,lInter,lVisua)

If Len(aVetInt) == 0
	Return
Endif

If lInter
	If nCol == nFd2Des .And. aVetInt[nLin][nFd2Leg] 
		lEditCell( @aVetInt , @oLbxInt , "@!" , nCol )
	Endif
Endif
 
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fCarga2  ¦ Autor ¦  Fabrica ERPBR ¦ 	  Data ¦  25/04/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Filtra dados para browse1 - usuários em cópia.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fCarga2(lCabec,lCopia,lInter,lVisua,aVetInt)

If !lCabec
	DbSelectArea("ZC3")
	DbSetOrder(1)
	DbSeek( xFilial("ZC3") + ZC1->ZC1_NUM )
	While !Eof() .And. ZC3->(ZC3_FILIAL+ZC3_NUM) == xFilial("ZC3") + ZC1->ZC1_NUM
		AAdd(aVetInt,{.F., ZC3->ZC3_CODUSU, ZC3->ZC3_NOMUSU, ZC3->ZC3_DATA, ZC3->ZC3_HORA, ZC3->ZC3_DESCRI })
		ZC3->(DbSkip())
	Enddo
Endif

If lInter
	AAdd(aVetInt,{.T., __cUserId, cUserName, Date(), Substr(Time(),1,5), Space(250) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _Validar  ¦ Autor ¦ Fabrica ERPBR ¦   Data ¦  25/04/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao geral da interface.		  					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _Validar(lCabec,lCopia,lInter,lVisua,aVetCop,aVetInt)

Local lRet := .T.
Local _x

If lCabec

	If Empty(cTitCham)
		MsgAlert("Título do chamado não informado.")
		lRet := .F.
	ElseIf Empty(cClass)
		MsgAlert("Classe não informada.")
		lRet := .F.
	ElseIf Empty(cCriti)
		MsgAlert("Criticidade não informada.")
		lRet := .F.
	ElseIf Empty(cDepto)
		MsgAlert("Depto. não informado.")
		lRet := .F.
	ElseIf Empty(cDescri)
		MsgAlert("Descrição não informada.")
		lRet := .F.
	Endif

ElseIf lCopia

	For _x := 1 to Len(aVetCop)
		If aVetCop[_x][nFd1Leg]
			If Empty(aVetCop[_x][nFd1Eml]) 
				MsgAlert("Email não adicionado na cópia.")
				lRet := .F.
			Endif
		Endif	
	Next _x

ElseIf lInter

	If Empty(cClass)
		MsgAlert("Classe não informada.")
		lRet := .F.
	Else	
		For _x := 1 to Len(aVetInt)
			If aVetInt[_x][nFd2Leg]
				If Empty(aVetInt[_x][nFd2Des]) 
					MsgAlert("Descrição não informada na interação do chamado.")
					lRet := .F.
				Endif
			Endif	
		Next _x
	Endif
	
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ _GravaInf  ¦ Autor ¦ Fabrica ERPBR ¦  Data ¦  25/04/2020	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Gravação dos dados.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _GravaInf(lCabec,lCopia,lInter,lVisua,aVetCop,aVetInt)

Local _x

If lCabec

	RecLock("ZC1",.T.)
	ZC1->ZC1_FILIAL := xFilial("ZC1")
	ZC1->ZC1_NUM    := cChamado 
	ZC1->ZC1_TITULO := cTitCham
	ZC1->ZC1_DATA   := dDataChm
	ZC1->ZC1_HORA   := cHoraChm
	ZC1->ZC1_CODUSU := cCodUsu
	ZC1->ZC1_NOMUSU := cNomUsu
	ZC1->ZC1_EMLUSU := cEmlUsu
	ZC1->ZC1_DEPTO  := cDepto
	ZC1->ZC1_CRITIC := cCriti
	ZC1->ZC1_CLASSE := cClass
	ZC1->ZC1_DESCRI := cDescri
	ZC1->ZC1_STATUS := "A"
	MsUnLock()

	For _x := 1 to Len(aVetCop)
		If !Empty(aVetCop[_x][nFd1Eml])
			RecLock("ZC2",.T.)
			ZC2->ZC2_FILIAL := xFilial("ZC2")
			ZC2->ZC2_NUM    := cChamado
			ZC2->ZC2_CODUSU := aVetCop[_x][nFd1Cod]
			ZC2->ZC2_NOMUSU := aVetCop[_x][nFd1Usu]
			ZC2->ZC2_EMLUSU := aVetCop[_x][nFd1Eml]
			MsUnLock()
		Endif
	Next _x

	u_MailCham(lCabec,lCopia,lInter,lVisua)

ElseIf lCopia

	For _x := 1 to Len(aVetCop)
		If aVetCop[_x][nFd1Leg]
			If !Empty(aVetCop[_x][nFd1Eml]) 
				RecLock("ZC2",.T.)
				ZC2->ZC2_FILIAL := xFilial("ZC2")
				ZC2->ZC2_NUM    := cChamado
				ZC2->ZC2_CODUSU := aVetCop[_x][nFd1Cod]
				ZC2->ZC2_NOMUSU := aVetCop[_x][nFd1Usu]
				ZC2->ZC2_EMLUSU := aVetCop[_x][nFd1Eml]
				MsUnLock()
			Endif
		Endif	
	Next _x

	u_MailCham(lCabec,lCopia,lInter,lVisua)
	
ElseIf lInter

	For _x := 1 to Len(aVetInt)
		If aVetInt[_x][nFd2Leg]
			If !Empty(aVetInt[_x][nFd2Des]) 
				RecLock("ZC3",.T.)
				ZC3->ZC3_FILIAL := xFilial("ZC3")
				ZC3->ZC3_NUM    := cChamado
				ZC3->ZC3_CODUSU := aVetInt[_x][nFd2Cod]
				ZC3->ZC3_NOMUSU := aVetInt[_x][nFd2Usu]
				ZC3->ZC3_DATA   := aVetInt[_x][nFd2Dat]
				ZC3->ZC3_HORA   := aVetInt[_x][nFd2Hor]
				ZC3->ZC3_DESCRI := aVetInt[_x][nFd2Des]
				MsUnLock()
			Endif
		Endif	
	Next _x

	RecLock("ZC1",.F.)
	ZC1->ZC1_STATUS := IIf(__cUserId $ (cUsrConst), "S", "C")
	ZC1->ZC1_CLASSE := cClass
	MsUnLock()

	u_MailCham(lCabec,lCopia,lInter,lVisua)	

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao   ¦ MailCham   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Chamada para envio email.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MailCham(lCabec,lCopia,lInter,lVisua)

MsgRun("Enviando e-mail... aguarde","Processando",{|| _ChmMail(lCabec,lCopia,lInter,lVisua) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _ChmMail  ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Envio do chamado via email .								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _ChmMail(lCabec,lCopia,lInter,lVisua)

Local cAssunto := "Chamado No."+ZC1->ZC1_NUM+" - "+AllTrim(CapitalAce(ZC1->ZC1_TITULO))//+IIf(lCabec,"Abertura",IIf(lCopia,"Add Cópia",IIf(lInter,"Interação")))
Local aMensage := {}
Local zEmail  := AllTrim(ZC1->ZC1_EMLUSU)
Local zCopias  := ""
Local zAttach  := ""
Local _x

AAdd(aMensage, "Usuário: "+AllTrim(ZC1->ZC1_NOMUSU))
AAdd(aMensage, "")
AAdd(aMensage, "Data: "+DtoC(ZC1->ZC1_DATA)+" || Hora: "+AllTrim(ZC1->ZC1_HORA))
AAdd(aMensage, "")
AAdd(aMensage, "Classe: "+AllTrim(ZC1->ZC1_CLASSE)+" || Criticidade: "+AllTrim(ZC1->ZC1_CRITIC)+" || Depto.: "+AllTrim(ZC1->ZC1_DEPTO))
AAdd(aMensage, "")
AAdd(aMensage, "<STRONG>Descrição:</STRONG>")
AAdd(aMensage, AllTrim(ZC1->ZC1_DESCRI))

DbSelectArea("ZC3")
DbSetOrder(1)
If DbSeek( xFilial("ZC3") + ZC1->ZC1_NUM )
	AAdd(aMensage, "")
	AAdd(aMensage, "<STRONG>Interações:</STRONG>")
	While !Eof() .And. ZC3->(ZC3_FILIAL+ZC3_NUM) == xFilial("ZC3") + ZC1->ZC1_NUM
		AAdd(aMensage, "")
		AAdd(aMensage, "<STRONG>"+AllTrim(ZC3->ZC3_NOMUSU)+" || Data: "+DtoC(ZC3->ZC3_DATA)+" || Hora: "+AllTrim(ZC3->ZC3_HORA)+"</STRONG>")		
		AAdd(aMensage, AllTrim(ZC3->ZC3_DESCRI))
		AAdd(aMensage, "")
		ZC3->(DbSkip())
	Enddo 
Endif

If GetMv("MV_SCHDPRO") // Só envia cópias no Ambiente de Produção
	DbSelectArea("ZC2")
	DbSetOrder(1)
	If DbSeek( xFilial("ZC2") + ZC1->ZC1_NUM )
		While !Eof() .And. ZC2->(ZC2_FILIAL+ZC2_NUM) == xFilial("ZC3") + ZC1->ZC1_NUM
			zCopias += IIf(!Empty(zCopias),";","") + AllTrim(ZC2->ZC2_EMLUSU)
			ZC2->(DbSkip())
		Enddo 
	Endif
Endif

// Adiciona consultores na cópia
nPosic  := 0
aLinha  := {}
cTxtLin := cUsrConst
While (!Empty(cTxtLin))
	If (((nPosic := AT(";",cTxtLin)) > 0))
		AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
		cTxtLin := Stuff(cTxtLin,1,nPosic,"")
	Else
		AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
		cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
	Endif	
Enddo
For _x := 1 to Len(aLinha)
 	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(UsrRetMail(aLinha[_x]))	
Next _x

zResult := U_TMailChm(zEmail, cAssunto, aMensage, zAttach, zCopias)
MsgInfo(zResult,"Aviso")

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ TMailChm ¦  Autor ¦ Luis Brandini   ¦   Data  ¦ 07/05/2020 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Objeto para envio de email.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TMailChm(zEmail, zAssunto, aMensage, zAttach, zCopias)

Local oServer
Local oMessage

Local zSmtp     := Alltrim(GetMv("MV_RELSERV")) // Nome do Servidor de Envio de E-mail utilizado nos relatorios
Local nPosPort  := AT(":",zSmtp)
Local zServer	:= IIf(nPosPort > 0, Substr(zSmtp,1,nPosPort-1), zSmtp)
Local zPorta    := IIf(nPosPort > 0, Val(Substr(zSmtp, nPosPort+1, Len(zSmtp)-nPosPort)), 587)
Local zAccount  := Alltrim(GetMv("MV_RELACNT")) // Conta a ser utilizada no envio de E-Mail para os relatorios
Local zPassword := Alltrim(GetMv("MV_RELPSW"))  // Senha da Conta de E-Mail para envio de relatorios 
Local lUseAuth	:= GetMv("MV_RELAUTH") // Servidor de E-Mail necessita de Autenticacao ?
Local zUserAuth := Alltrim(GetMv("MV_RELAUSR")) // Usuario para Autenticacao no Servidor de E-Mail
Local zPassAuth := Alltrim(GetMv("MV_RELAPSW")) // Senha para autenticacao no servidor de E-Mail
Local zEmlFrom  := Alltrim(GetMv("MV_RELFROM")) // E-mail utilizado no campo FROM no envio de relatorios por E-mail
Local lUseSSL   := GetMv("MV_RELSSL")
Local lUseTLS   := GetMv("MV_RELTLS")
Local zResult   := "E-mail enviado com sucesso."
Local zBody     := ""
Local zMsgFim   := "Por favor não responda essa mensagem. Esse é um e-mail automático."
Local nInd

oServer := TMailManager():New()
oServer:SetUseSSL(lUseSSL)
oServer:SetUseTLS(lUseTLS)
oServer:Init("", zServer, zAccount, zPassword, 0, zPorta)

zRet := oServer:SetSmtpTimeOut(30)
If zRet != 0
	zMsgRet := "Falha ao setar o time out: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

zRet := oServer:SmtpConnect()
If zRet != 0
	zMsgRet := "Falha ao conectar no servidor de email: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

If lUseAuth
	zRet := oServer:SmtpAuth(zUserAuth, zPassAuth)
	If zRet != 0
		zMsgRet := "Falha na autenticação do servidor smtp: "+oServer:GetErrorString(zRet)
		Conout(zMsgRet)
		zResult := zMsgRet
		Return(zResult)
	Endif
Endif

zBody += '<DIV><FONT face=Arial size=2><IMG alt="" hspace=0 border=0></FONT></DIV>'
zBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
zBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
zBody += 'size=3><STRONG>TOTVS12 - Serviço de envio de mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 to Len(aMensage)
	zBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMensage[nInd] + '</SPAN></FONT></DIV><p>'
Next nInd
zBody += '<DIV><FONT face=Verdana color=#ff0000 size=2><SPAN class=216593018-10022004>' + zMsgFim + '</SPAN></FONT></DIV><p>'

oMessage := TMailMessage():New()
oMessage:Clear()
oMessage:cFrom    := zEmlFrom
oMessage:cTo      := zEmail
oMessage:cCc      := zCopias
oMessage:cBcc     := ""
oMessage:cSubject := zAssunto
oMessage:cBody    := zBody

If !Empty(zAttach)
	If oMessage:AttachFile(zAttach) < 0
		zMsgRet := "Erro ao atachar o arquivo."
		Conout(zMsgRet)
		zResult := zMsgRet
		Return(zResult)
	Endif
Endif

zRet := oMessage:Send(oServer)
If zRet != 0
    zMsgRet := "Erro ao enviar o e-mail: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
   
zRet := oServer:SmtpDisconnect()
If zRet != 0
	zMsgRet := "Erro ao disconectar do servidor smtp: "+oServer:GetErrorString(zRet)
	Conout(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
  
Return(zResult)
