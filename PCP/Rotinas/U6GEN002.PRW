#Include "Protheus.ch"                      
#Include "FWBROWSE.CH"
#INCLUDE "TBICONN.CH" 

/*
Autor       : Wederson L. Santana
Data/Hora   : 29/09/2020    - 13/08/2021
Revisão		: MRP / DPE
Data/Hora   : 
Módulo      : Estoque -  PCP - Compras

-------------------------------------------

Atualização do processo - 11/02/2022

*/

*---------------------*
User Function U6GEN002
*---------------------*

Local aSize     := {}
Local aObjects	:= {}

Local oLayer 	:= FWLayer():New()

Private aPanel	:= {}
Private oDlg
Private oTButton2

Private oBrowP  
Private oBrowC
Private oBrowE
Private oBrowV
		
Private nMetSB1:= 0
Private oMetSB1
Private oSaySB1
Private nMetSGG:= 0
Private oMetSGG
Private oSaySGG

Private lChkSB1:= .F.
Private lChkSGG:= .F.

Private aFiles 		:= {}
Private lEnvEmail	:= .T. //Parametro que define se envia e-mail na integração de arquivos

Private xPreSel		:= ""
Private cLocalArq   := ""
Private cCodSb1     := Space(TamSx3("B1_COD")[1])

Private aLogErros   := {}
Private aCpObg      := {"B1_COD","B1_DESC","B1_TIPO","B1_UM","B1_GRUPO","B1_CONTA","B1_LOCPAD","B1_POSIPI","B1_ORIGEM","B1_P_TIP"}
Private aCpObgEst   := {"ITEM","QTY","PART NUMBER","LEVEL"}

// Faz o calculo automatico de dimensoes de objetos
aSize := MsAdvSize()

AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )    

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE DIALOG oDlg TITLE "Integracao " FROM aSize[7],0 To aSize[6],aSize[5] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

oFont:= TFont():New('Arial',,-14,,.f.)
        
oLayer:init(oDlg,.F.,.T.)              

oLayer:addCollumn('ESQ',15,.F.)
oLayer:addCollumn('DIR',85,.F.)
        
oLayer:addWindow('ESQ','WinEC','',20,.F.,.F.,{||  },,{||  })
oLayer:addWindow('ESQ','WinEB','Opções',80,.F.,.F.,{||  },,{||  })
		
oLayer:addWindow('DIR','WinDU','',100,.F.,.T.,{||  },,{|| })
        
oWinEC := oLayer:getWinPanel('ESQ','WinEC')
oWinEB := oLayer:getWinPanel('ESQ','WinEB')
		
//oWinEU := oLayer:getWinPanel('ESQ','WinEU','UNICO')
oWinDU := oLayer:getWinPanel('DIR','WinDU')
        
oLayer:setColSplit('ESQ',CONTROL_ALIGN_RIGHT)
				
//Botões
oBtn1 := TBtnBmp2():New( 01,02,26,26,'FINAL',,,,{||oDlg:end()},oWinEC,,,.T. )
oBtn1:cTooltip:="Sair"
        
oTree := DbTree():New(01,0,360,260,oWinEB,{|| ShowItem(oTree:GetCargo()) },,.T.)
		
AADD(aPanel,CriaPain(oWinDU,"Parâmetro","PMSTASK3",1,3))
AADD(aPanel,CriaPain(oWinDU,"Prod-DPE" ,"PMSTASK3",1,3))
AADD(aPanel,CriaPain(oWinDU,"Estr-DPE" ,"PMSTASK3",1,3))
						
CriaTemp()
				
TlParame(aPanel[1])
TlProd(aPanel[2])
TlEstr(aPanel[3])

ACTIVATE DIALOG oDlg CENTERED ON INIT( ) 

Return

/*
Função para criar a árvore(tree) vinculado a um painel da direita
oBjt	: Objeto onde será criado o painel
cNome	: Descrição do item da árvore
cImg	: Imagem do item da árvore
nTipo	: Indica o nível que o item ou subitem será adicionado, sendo: 1=No mesmo nível ou 2=Abaixo
*/
*-------------------------------------------------------*
Static Function CriaPain(oBjt,cNome,cImg,nTipo,nQualTree)
*-------------------------------------------------------*
Local cPanel:= "o"+CriaTrab(NIL, .F.)

//Cria o painel com o mesmo nome do item da Tree
&(cPanel):= tPanel():New(01,01,"",oBjt,,,,,,100,100)
&(cPanel):align:= CONTROL_ALIGN_ALLCLIENT
&(cPanel):cReadVar:=cPanel

if nQualTree==1
	//Cria um item da tree com o nome do painel
	//oTree:AddItem(cNome,cPanel, cImg ,,,,nTipo) 
	oTree:AddTree(cNome,.T.,cImg,cImg,,,cPanel)
elseif nQualTree==2
	oTree:AddTreeItem(cNome,cImg,,cPanel)
else
	oTree:AddItem(cNome,cPanel, cImg ,,,,nTipo) 
endif

//oTree:AddTreeItem(cNome,cImg,,cPanel)

if len(aPanel)<>0
	&(cPanel):Hide()
endif

Return&(cPanel)


//Função para tornar visível o painel de acordo com o item da árvore posicionado
*------------------------------*
Static Function ShowItem(cItem)
*------------------------------*
Local i	:= 0 

for i:=1 to len(aPanel)
	if aPanel[i]:cReadVar==cItem
		aPanel[i]:Show()
	else
		aPanel[i]:Hide()
	endif
next

Return

//Cria as tabelas temporárias
*--------------------------*
Static function CriaTemp()
*--------------------------*
//-->INICIO - Tabela temporária 
Local aDadTemp	:= {}

AADD(aDadTemp,{"LSTATUS"	,"L",1,0})
AADD(aDadTemp,{"ID"			,"C",6,0})
AADD(aDadTemp,{"TAB"		,"C",3,0})
AADD(aDadTemp,{"USUARIO"	,"C",20,0})
AADD(aDadTemp,{"DATAGE"		,"D",8,0})
AADD(aDadTemp,{"HORA"		,"C",10,0})
AADD(aDadTemp,{"ARQUIVO"	,"C",40,0})
AADD(aDadTemp,{"LINHA"		,"C",20,0})
AADD(aDadTemp,{"LOG"		,"C",200,0})

//tabela temporária de produtos
if select("TRBSB1")>0
	TRBSB1->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSB1",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)
IndRegua("TRBSB1",cIndex,"ID",,,"Selecionando Registro...")  

DbSelectArea("TRBSB1")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//tabela temporária de estrutura de produtos
if select("TRBSGG")>0
	TRBSGG->(DbCloseArea())
endif
// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"TRBSGG",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("TRBSGG",cIndex,"ID",,,"Selecionando Registro...")  

dbSelectArea("TRBSGG")
dbSetIndex(cIndex+OrdBagExt())
dbSetOrder(1)

Return

//Tela para seleção dos arquivos, são os parâmetros para processamento
*------------------------------*
Static Function TlParame(oLocal)
*------------------------------*
Local oGetSB1
Local oChkSB1
Local cLocaSB1 :=""

Local oGetProd
Local oChkProc
Local cLocaSGG :=""
 
oFontBtn:= TFont():New('Arial',,-16,.T.,.F.)

oGroup1:= tGroup():New(010,03,210,330,'Selecione os arquivos para integração - DPE:',oLocal,,,.T.)

oGroup3:= tGroup():New(215,03,270,565,'',oLocal,,,.T.)

oGroup4:= tGroup():New(010,340,210,565,'Iniciar o processo:',oLocal,,,.T.)

oTButton := TButton():New( 050, 400, " Integrar ",oLocal,{|| Controle(cLocaSB1,cLocaSGG) },55,20,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

oTButton :cTooltip = "Integrar"

oChkSB1 := TCheckBox():New(27,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkSB1:bSetGet := {|| lChkSB1 }
oChkSB1:bLClicked := {|| lChkSB1:=!lChkSB1 }

@ 27,25 SAY "Arquivo de Produtos: " SIZE 100,10 OF oLocal PIXEL
oGetSB1:= TGet():New(25,100,{|u| if(PCount()>0,cLocaSB1:=u,cLocaSB1)}, oLocal,190,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSB1')
oTButton := TButton():New( 25, 295, "...",oLocal,{||fAbreCSV(@cLocaSB1,oGetSB1)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

oGetSB1:Disable()

@ 60,10 Say "Project" SIZE 150,10 OF oLocal PIXEL
 oGetProd := TGet():New( 58, 030, { | u | If( PCount() == 0, cCodSb1, cCodSb1 := u ) },oLocal, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,"SB1","cCodSb1",,,,  )
//oGet1 := TGet():New( 028,076,bSetGet(_cProd),oDlg1,060,008,'@!',{||If(PCount()>0,U_XVERIF(_cProd,1),"")},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","_cProd",,)	 

//----------------------------------------

oChkProc := TCheckBox():New(77,10,'',,oLocal,100,210,,,,,,,,.T.,,,)
oChkProc:bSetGet := {|| lChkSGG }
oChkProc:bLClicked := {|| lChkSGG:=!lChkSGG }

@ 77,25 SAY "Arquivo BOM: " SIZE 100,10 OF oLocal PIXEL
oChkProc:= TGet():New(75,120,{|u| if(PCount()>0,cLocaSGG:=u,cLocaSGG)}, oLocal,170,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cLocaSGG')
oTButton := TButton():New( 75, 295, "...",oLocal,{||fAbreCSV(@cLocaSGG,oGetProd)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
                 
oChkProc:Disable()

nMetSB1 := 0
oSaySB1 := tSay():New(220,20,{||'Processando produtos ...'},oLocal,,,,,,.T.,,,100,20)
oMetSB1 := TMeter():New(230,15,{|u|if(Pcount()>0,nMetSB1:=u,nMetSB1)},100,oLocal,535,26,,.T.)

oMetSB1:Hide()
oSaySB1:Hide()

nMetSGG := 0
oSaySGG := tSay():New(220,20,{||'Processando estrutura ...'},oLocal,,,,,,.T.,,,100,20)
oMetSGG := TMeter():New(230,15,{|u|if(Pcount()>0,nMetSGG:=u,nMetSGG)},100,oLocal,535,26,,.T.)

oMetSGG:Hide()
oSaySGG:Hide()

Return

//Função para controle do processamento, o que está marcado para ser executado
*-------------------------------------------------------------*
Static function Controle(cLocaSB1,cLocaSGG)
*-------------------------------------------------------------*
Local lRet		:= .F.
Local lTemMak   := .F.

aFiles:={} //Limpa o array que fica os arquivos para anexo

If lChkSB1
	oMetSB1:Show()
	oSaySB1:Show()
		
	If !LeArqDPE(cLocalArq,"SB1")
		oMetSB1:Hide()
		oSaySB1:Hide()
	Else
		lRet:=.T.
		AADD(aFiles,cLocalArq)
	Endif
		
	lTemMak:=.T.
EndIf

If lChkSGG
   If SGG->(FieldPos("GG_XXITEM")) > 0
   
   	  If! Empty(cCodSb1)
   		  SB1->(dbSetOrder(1))
   		  If SB1->(dbseek(xFilial("SB1")+cCodSb1))

			 oMetSGG:Show()
			 oSaySGG:Show()
		
			 If !LeArqDPE(cLocalArq,"SGG")
				oMetSGG:Hide()
				oSaySGG:Hide()
			 Else
				lRet:=.T.
				AADD(aFiles,cLocalArq)
			 EndIf

		  Else
        	 MsgInfo("Verifique cadastro para o produto: "+AllTrim(cCodSb1)+".","A t e n ç ã o")
		  EndIf
	  Else
          MsgInfo("Informe um cadastro válido.","A t e n ç ã o")
	  EndIf  
    Else
        MsgInfo("Campo obrigatório não encontrado no ambiente.","A t e n ç ã o - Contate o administrador")
	EndIf     
		
	lTemMak:=.T.
EndIf
	
If !lTemMak
	AVISO("Atenção", "Nenhuma opção selecionada", { "OK"}, 1)	
EndIf

If lRet
	
	AVISO("Processo concluído com sucesso.", "Arquivo(s) processado(s), verifique o cadastro no sistema.", { "OK"}, 1)	 
	oDlg:end()	
	
EndIf

Return

//------------------------------

Static Function fAbreCsv(cGet,oGet)

Local cTitle		:= "Salvar arquivo"
Local cFile 		:= "Arq.csv  | *.csv"
Local nDefaultMask 	:= 1
Local cDefaultDir  	:= "C:\"
Local nOptions		:= GETF_LOCALHARD + GETF_LOCALFLOPPY
Local cRet			:= ""

//Exibe tela para gravar o arquivo.
cRet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

if !Empty(cRet)
	cGet:=cRet
endif

oGet:Refresh()
cLocalArq:=cRet
Return

//Tela de visualização de log de produtos
*------------------------------*
Static Function TlProd(oLocal)
*------------------------------*
Local oBrowP

// Define o Browse	
DEFINE FWBROWSE oBrowP DATA TABLE ALIAS "TRBSB1" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowP| /* Função que atualiza a regra*/ }  OF oBrowP

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowP		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowP		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowP		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowP	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowP	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowP	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20 OF oBrowP	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowP	

oBrowP:SetFilterDefault('TAB == "SB1"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowP

Return

//Tela de visualização de log de estrutura de produtos
*------------------------------*
Static Function TlEstr(oLocal)
*------------------------------*
Local oBrowE

// Define o Browse	
DEFINE FWBROWSE oBrowE DATA TABLE ALIAS "TRBSGG" OF oLocal			

//Adiciona coluna para marcar e desmarcar
ADD MARKCOLUMN 		oColumn DATA { || If(LSTATUS,"BR_VERDE","BR_VERMELHO") } DOUBLECLICK { |oBrowE| /* Função que atualiza a regra*/ }  OF oBrowE

// Adiciona as colunas do Browse	   	
ADD COLUMN oColumn DATA { || ID			} TITLE "Código"   			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 06 OF oBrowE		
//ADD COLUMN oColumn DATA { || TAB	   	} TITLE "Tabela"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 3 OF oBrowE		
ADD COLUMN oColumn DATA { || USUARIO   	} TITLE "Usuário"			DOUBLECLICK  {||  			}	ALIGN 1 SIZE 20 OF oBrowE		
ADD COLUMN oColumn DATA { || DATAGE    	} TITLE "Data"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 08 OF oBrowE	
ADD COLUMN oColumn DATA { || HORA    	} TITLE "Hora"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 10 OF oBrowE	
ADD COLUMN oColumn DATA { || ARQUIVO   	} TITLE "Arquivo"			DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 40 OF oBrowE	
ADD COLUMN oColumn DATA { || LINHA  	} TITLE "Linha"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 20	OF oBrowE	
ADD COLUMN oColumn DATA { || LOG    	} TITLE "Log"				DOUBLECLICK  {|| 			} 	ALIGN 1 SIZE 200 OF oBrowE	

oBrowE:SetFilterDefault('TAB == "SGG"')

// Ativação do Browse	
ACTIVATE FWBROWSE oBrowE

Return

// Wederson L. Santana
//Função genérica para abertura e leitura dos arquivos
*----------------------------------------*
Static Function LeArqDPE(cArq,cTab,cTab2)
*----------------------------------------*
//Local oFT   	:= FT():New()
//Local cLinha	:= ""
//Local cToken	:= ";"
//Local aLinha	:= {}
//Local nTotLin	:= 0
//Local lErro		:= .F.
//Local lCrt		:= .F.
//Local lTemDup   := .F.   
//Local cTemDup   := "" 
//Local aCampos	:= {}
//Local nPos		:= 0
//Local lCpoFal	:=.F.
//Local aCpoObrigat	:= {} 
//Local cCpoFaltantes :=""
//Local nHdle		:= 0
Local aColunas  :={}
Local aDadosCSV :={}
Local aDadosItem:={}
Local nAtual    :=0
Local nProx     :=0
Local nColunas  :=0
Local lSair     := .F.
Local lRet      := .F.
Local nI        := 1
Local lCampos   := .T.
Local nPosItEst := 0
Local nLinha    := 1

DEFAULT cTab2	:= ""  

nHandle := FT_FUse(cArq)

If! nHandle = -1
    
    FT_FGoTop()

    nLast := FT_FLastRec()
    While !FT_FEOF()
           cLine  := FT_FReadLn()

           If FT_FRecno() == 1
                nAtual:=1
				nProx:=0
				While! lSair
				      nProx:= at(";",cLine,nAtual)
  					  If nProx == 0
					     lSair :=.T.
						 nProx := Len(cLine)+1
					  EndIf
				      aadd(aColunas,{SubStr(cLine,nAtual,(nProx - nAtual))})
					  nAtual := nProx+1
					  nColunas ++
				End
				aadd(aColunas,{"Linha"})
		   Else
			    lSair    :=.F.
                nAtual   :=1
				nProx    :=0
				nColunas :=0
				While! lSair 
				      nProx:= at(";",cLine,nAtual)
					  If nProx == 0
					     lSair :=.T.
						 nProx := Len(cLine)+1
					  EndIf
				      aadd(aDadosCSV,{SubStr(cLine,nAtual,(nProx - nAtual))})
					  nAtual := nProx+1
					  nColunas ++
				End
				aadd(aDadosCSV,{nLinha})
        		If cTab = "SB1"
					If AsCan(aColunas, {|x| AllTrim(x[1]) == "B1_COD" }) >0
				   		If! Empty(aDadosCSV[1][AsCan(aColunas, {|x| AllTrim(x[1]) == "B1_COD" })])
                	   		AAdd(aDadosItem,aDadosCSV)				       
				   		Else
				       		AAdd(aLogErros,{"Produto",AllTrim(aDadosCSV[1][AsCan(aColunas, {|x| AllTrim(x[1]) == "B1_COD" })])," Código do produto obrigatório e não informado.Verifique os dados no arquivo.",cArq,nLinha})	   
				   		EndIf	  
					Else
				    	AAdd(aLogErros,{"Campo B1_COD",""," Código do produto obrigatório e não informado.Verifique os dados no arquivo.",cArq,nLinha})	   
					EndIf   
				Else
				    nPosItEst:=AsCan(aColunas, {|x| AllTrim(x[1]) == "Item" })
				    If nPosItEst >0
					   If! Empty(aDadosCSV[1][nPosItEst] )
					       aDadosCSV[1][nPosItEst] := StrTran(aDadosCSV[1][nPosItEst],",",".")
                           AAdd(aDadosItem,aDadosCSV)				       
					   Else
                           AAdd(aLogErros,{"Item",""," Item  não informado para a estrutura. Verifique os dados no arquivo.",cArq,nLinha})	   
                       EndIf
					Else   
                        AAdd(aLogErros,{"Estrutura Item",""," Item da estrutura obrigatório e não informado.Verifique os dados no arquivo.",cArq,nLinha})	   
					EndIf    
				EndIf	
				aDadosCSV :={}
		   EndIf 
           FT_FSKIP()
		   nLinha ++
    End
EndIf

Do Case
	Case cTab == "SGG"
	     
		 For nI:=1 To Len(aCpObgEst)

	   		If AsCan(aColunas, {|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aCpObgEst[nI])) }) == 0
               
			   lCampos:= .F.
			   
			   AAdd(aLogErros,{"ESTRUTURA",AllTrim(aCpObgEst[nI])," Campo obrigatório não informado.Verifique os dados no arquivo.",cArq,1})
               
	   		EndIf

		Next   

		If lCampos 
		   lRet:=ExecASGG(aColunas,aDadosItem,cArq)//Chamada da função de execauto.
        Else
		    MsgInfo("Existem campos obrigatórios não informados."," A t e n ç ã o")
		EndIf
    
    Case cTab == "SB1"

    	For nI:=1 To Len(aCpObg)

	   		If AsCan(aColunas, {|x| AllTrim(x[1]) == AllTrim(aCpObg[nI]) }) == 0
               
			   lCampos:= .F.
			   
			   AAdd(aLogErros,{"Produto",AllTrim(aCpObg[nI]),FWSX3Util():GetDescription( AllTrim(aCpObg[nI]) )+" Campo obrigatório não informado.Verifique os dados no arquivo.",cArq,1})
               
	   		EndIf

		Next nI  

		If lCampos 
			lRet:=ExecDpe(aColunas,aDadosItem,cArq)//Chamada da função de execauto.
        Else
		    MsgInfo("Existem campos obrigatórios não informados."," A t e n ç ã o")
		EndIf
EndCase

If! lCampos
	If Len(aLogErros)>0 
        If MsgYesNo("Deseja gerar o log da importação?","")
   			fImprime(cArq)
		EndIf    
	EndIf
EndIf

FT_FUSE()
	
Return(lRet)


//----------------------------------------------------------------------------------

Static Function ExecDpe(aColunas,aDadosItem,cArq)  

Local xAutoCab 	:= {}
Local lErro		:= .F.
Local nX
Local nY
Local cCodProd := ""

//Campos comuns aos 2, Produtos e clientes
Local nPosCod	:= 1
Local nTotLin   := Len(aDadosItem)
Local nAumenta  := (100/(nTotLin-2)) 
Local cMens     := ""
Local lAltera   := .F.
Local nLinha    := 0

Private lMsErroAuto:= .F.
Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.

nCurrent:=0 //Inicial o controle da régua

For nX:=1 To Len(aDadosItem)
	xAutoCab := {}
	
	nCurrent+=Round(nAumenta,2) // atualiza régua
	If nCurrent>100
	   nCurrent:=100
	EndIf
	oMetSB1:Set(nCurrent)
    
	nPosCod	 := AScan(aColunas, {|x| AllTrim(x[1]) == "B1_COD"})
    cCodProd := AllTrim(aDadosItem[nX][1][nPosCod])
	
	For nY:=1 to Len(aColunas)
		
		If SB1->(FieldPos(aColunas[nY][1])) > 0

           If lAltera 
		      If (AsCan(aCpObg, {|x| AllTrim(x) == AllTrim(aColunas[nY][1]) })) == 0
                 				 
			  		If TAMSX3(aColunas[nY][1])[3]=="C"
						If aColunas[nY][1] == "B1_DESC"
							aDadosItem[nX][nY][1] := Substr(aDadosItem[nX][nY][1],1,TamSx3("B1_DESC")[1])
						Endif
						If aColunas[nY][1] == "B1_LOCPAD"
							aDadosItem[nX][nY][1] := StrZero(Val(aDadosItem[nX][nY][1]),2)
						Endif
						AADD(xAutoCab,{aColunas[nY][1] , UPPER(alltrim(aDadosItem[nX][nY][1]))	,nil})
					ElseIf TAMSX3(aColunas[nY][1])[3]=="N"
			       			If Val(StrTran(aDadosItem[nX][nY][1],",",".")) > 0
            	       			AADD(xAutoCab,{aColunas[nY][1] , Val(StrTran(aDadosItem[nX][nY][1],",","."))	, nil})
				   			EndIf	   
					Else
						AADD(xAutoCab,{aColunas[nY][1] , aDadosItem[nX][nY][1]	, nil})
					EndIf
				 
			  EndIf
		   Else

				If TAMSX3(aColunas[nY][1])[3]=="C"
					If aColunas[nY][1] == "B1_DESC"
						aDadosItem[nX][nY][1] := Substr(aDadosItem[nX][nY][1],1,TamSx3("B1_DESC")[1])
					Endif
					If aColunas[nY][1] == "B1_LOCPAD"
						aDadosItem[nX][nY][1] := StrZero(Val(aDadosItem[nX][nY][1]),2)
					Endif
					AADD(xAutoCab,{aColunas[nY][1] , Upper(AllTrim(NoAcento(aDadosItem[nX][nY][1])))	,nil})
				ElseIf TAMSX3(aColunas[nY][1])[3]=="N"
			       	  If Val(StrTran(aDadosItem[nX][nY][1],",",".")) > 0
            	         AADD(xAutoCab,{aColunas[nY][1] , Val(StrTran(aDadosItem[nX][nY][1],",","."))	, nil})
				   	  EndIf	   
				Else
					AADD(xAutoCab,{aColunas[nY][1] , aDadosItem[nX][nY][1]	, nil})
				EndIf

			EndIf
        Else
		    If aColunas[nY][1] == "Linha"
			   nLinha := aDadosItem[nX][nY][1]
			EndIf
		EndIf	

	Next nY
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cCodProd)

	   MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,4)

	   cMens:= "Alteração "

       If lMsErroAuto

			cErroCon	:= ""
			aAutoErro 	:= GetAutoGrLog()
	    	cErroCon	:= SubStr(XLOG(aAutoErro),1,100 )
	   
			AAdd(aLogErros,{"Produto",cCodProd,cMens+"-"+Iif(Empty(cErroCon),"erro não identificado",cErroCon),cArq,nLinha})
	    	
	    	lErro:=.T.
	    	DisarmTransaction()

		Else
	    
         	AAdd(aLogErros,{"Produto",cCodProd,cMens+" realizada com sucesso",cArq,nLinha})

		 	lErro:=.F.
		
		EndIF

	Else

       MSExecAuto({|x,y| Mata010(x,y)},xAutoCab,3)

	   cMens:= "Inclusão "

	   If lMsErroAuto

			cErroCon	:= ""
			aAutoErro 	:= GetAutoGrLog()
	    	cErroCon	:= SubStr(XLOG(aAutoErro),1,100 )
	   
			AAdd(aLogErros,{"Produto",cCodProd,cMens+"-"+Iif(Empty(cErroCon),"erro não identificado",cErroCon),cArq,nLinha})
	    	
	    	lErro:=.T.
	    	DisarmTransaction()

	   Else
	    
         	AAdd(aLogErros,{"Produto",cCodProd,cMens+" realizada com sucesso",cArq,nLinha})

		 	lErro:=.F.
		
	   EndIF
	
	EndIf    
	
Next nX

If Len(aLogErros)>0 
   If MsgYesNo("Deseja gerar o log da importação?","")
   		fImprime(cArq)
   EndIf		   
EndIf

Return(.T.)

//--------------------------------------------

Static Function ExecASGG(aColunas,aDadosItem,cArq)  
Local nI, nZ

Local nTotLin   := Len(aDadosItem)
Local nAumenta  := (100/(nTotLin-2)) 

Local nPosItem	 := 0
Local nPosQty	 := 0
Local nPosPartN  := 0
Local nPosLevel  := 0
Local nPosStokN  := 0
Local nPosObserv := 0
Local nPosLin    := 0
Local cItemAnt   := ""
Local nTamAnt    := 0
Local nLinha     := 0
Local cItem      := ""
Local cCodComp   := ""
Local cNivelEst  := ""
Local nQuant     := 0
Local cCodStok   := ""
Local cObserv    := ""
Local cCodSup    := ""
Local aLenBom    := {}
Local nProx      := 0
Local nStart     := 1
Local cCodSGG    := ""
Local aNivEstru  := {}
Local nDtFim     := SuperGetMV("MV_XXDTFIM", .F.,770)

If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "ITEM"} ) >0
   nPosItem := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "ITEM"} )
EndIf 
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "QTY"} ) >0
	nPosQty := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "QTY"} )
EndIf 
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "PART NUMBER"} )>0
	nPosPartN := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "PART NUMBER"} )
EndIf 
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "LEVEL"} ) >0
	nPosLevel := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "LEVEL"} )		
EndIf
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "STOCK NUMBER"} )	>0 
	nPosStokN := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "STOCK NUMBER"} )	
EndIf 
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "MATERIAL"} ) >0
	nPosObserv := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "MATERIAL"} )		
EndIf 
If aScan( aColunas, { |x| Upper(alltrim(x[1])) == "LINHA"} ) >0
	nPosLin := aScan( aColunas, { |x| Upper(alltrim(x[1])) == "LINHA"} )		
EndIf

// Monta os níveis
aLastNiv := {}
cLastCod := ""
cLastNiv := ""
For nI:=1 To Len(aDadosItem)
	cNumItem  := AllTrim(aDadosItem[nI][nPosItem][1])
	cNivelEst := SubStr(aDadosItem[nI][nPosLevel][1],1)
	cCodComp  := SubStr(aDadosItem[nI][nPosPartN][1],1,TamSx3("GG_COD")[1])
	If cNivelEst == "1"
		For nZ := 1 to Len(aLastNiv)
			If aLastNiv[nZ][1] > "1"
				aLastNiv[nZ][1] := ""
				aLastNiv[nZ][2] := ""
			Endif	
		Next nZ
	Endif
	nPos := aScan(aLastNiv, {|x| x[1] == cNivelEst})
	If nPos == 0
		If Empty(cLastCod)
			cLastCod := cCodSb1
		Endif
		AAdd(aLastNiv, {cNivelEst, cLastCod}) // Nivel | Cód.Pai
	Endif	
	nPos := aScan(aLastNiv, {|x| x[1] == cNivelEst})
	If nPos > 0
		AAdd(aNivEstru,{cNumItem, cCodComp, aLastNiv[nPos][2], aLastNiv[nPos][1]}) // Item Seq. | Componente | Cód.Pai | Nível
	Endif
	cLastCod := cCodComp
	If cNivelEst < cLastNiv
		For nZ := 1 to Len(aLastNiv)
			If aLastNiv[nZ][1] > cNivelEst
				aLastNiv[nZ][1] := ""
				aLastNiv[nZ][2] := ""
			Endif	
		Next nZ
	Endif
	cLastNiv := cNivelEst
Next nI

nCurrent:=0 //Inicial o controle da régua
ASORT(aDadosItem,,, { |x, y| x[1][1] < y[1][1] } ) 

For nI:=1 To Len(aDadosItem)

	nCurrent+=Round(nAumenta,2) // atualiza régua
	If nCurrent>100
		nCurrent:=100
	EndIf
	oMetSGG:Set(nCurrent)
   
    If nPosPartN >0
       cCodComp:= SubStr(aDadosItem[nI][nPosPartN][1],1,TamSx3("GG_COD")[1])
	EndIf
    If nPosLevel >0
       cNivelEst := SubStr(aDadosItem[nI][nPosLevel][1],1)
	EndIf
	If nPosQty > 0
	   nQuant  := Val(aDadosItem[nI][nPosQty][1])
	EndIf
	If nPosStokN > 0
	   cCodStok:= SubStr(aDadosItem[nI][nPosStokN][1],1,TamSx3("GG_COD")[1])
	EndIf
	If nPosObserv >0 
	   cObserv := SubStr(aDadosItem[nI][nPosObserv][1],1,TamSx3("GG_OBSERV")[1])
	EndIf
	If nPosLin >0
	   nLinha  := aDadosItem[nI][nPosLin][1]
	EndIf

    dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+cCodComp)

		If SB1->B1_MSBLQL <> "1"

			cItem := AllTrim(aDadosItem[nI][nPosItem][1])

			If! "." $ AllTrim(aDadosItem[nI][nPosItem][1]) 

				nPos    := aScan(aNivEstru, {|x| x[1] == cItem .And. x[2] == cCodComp})
				cCodPai := PadR(AllTrim(aNivEstru[nPos][3]),TamSx3("GG_COD")[1])
				cNivEst := StrZero(Val(aNivEstru[nPos][4]),TamSx3("GG_TRT")[1])

				dbSelectArea("SGG")
				dbSetOrder(1)
				If! dbSeek(xFilial("SGG")+cCodPai+cCodComp)
					Reclock("SGG",.T.)
					SGG->GG_FILIAL  := xFilial("SGG")
					SGG->GG_COD     := cCodPai
					SGG->GG_COMP    := cCodComp
					SGG->GG_QUANT   := nQuant
					SGG->GG_PERDA   := 0
					SGG->GG_TRT     := cNivEst
					SGG->GG_INI     := dDataBase
					SGG->GG_FIM     := dDataBase + nDtFim
					SGG->GG_FIXVAR  := "V"
					SGG->GG_POTENCI := 0
					SGG->GG_STATUS  := "1"
					SGG->GG_USUARIO := LogUserName()
					SGG->GG_REVFIM  := "ZZZ"
					SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
					MsunLock()
					AAdd(aLogErros,{"Estrutura",cCodComp,"Componente incluído com sucesso na pré-estrutura do "+cCodPai+".",cArq,nLinha})
				Else
					AAdd(aLogErros,{"Estrutura",cCodComp,"Componente já existe na pré-estrutura do "+cCodPai+".",cArq,nLinha})
				EndIf	 

			Else

				aLenBom:={}
				nProx  :=0
				nStart :=1
				nSubs  :=0
				While nStart <= Len(cItem)
					nProx:= at(".",cItem,nStart)
					If nProx >0
						nStart := nProx+1
						nSubs  := at(".",cItem,nProx+1)
						If nSubs == 0
							nSubs := Len(cItem)
						Else
							nSubs --   
						EndIf
						aaDD(aLenBom,{subStr(cItem,1,nSubs)})

						If nStart >= Len(cItem)
							Exit
						EndIf
					Else
						Exit		   
					EndIf
			   Enddo

               nProx :=1
			   If Len(aLenBom)>1
                  nProx := Len(aLenBom)-1
			   EndIf

			   If Select("TRB") <> 0
	  			  TRB->(DbCloseArea())
   			   EndIf
                 
               cQuery:= "Select GG_COD,GG_COMP"
			   cQuery+= " From "+RetSqlName("SGG")
			   cQuery+= " Where D_E_L_E_T_ = '' "
			   cQuery+= " And GG_FILIAL = '"+xFilial("SGG")+"' "
			   cQuery+= " And GG_STATUS = '1' "
			   cQuery+= " And GG_XXITEM = '"+aLenBom[nProx][1]+"' "
               dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.F.)

		       If Empty(cCodStok) 
				 
				  cCodSGG := Iif(Empty(TRB->GG_COMP),cCodSb1,TRB->GG_COMP)

                  dbSelectArea("SB1")
				  dbSetOrder(1)
	              If dbSeek(xFilial("SB1")+cCodSGG)

                     If SB1->B1_MSBLQL <> "1"

				 		dbSelectArea("SGG")
			 			dbSetOrder(1)
			 			If! dbSeek(xFilial("SGG")+cCodSGG+cCodComp)

						    If AllTrim(cCodSGG)<>AllTrim(cCodComp)

             					Reclock("SGG",.T.)
                    			SGG->GG_FILIAL  := xFilial("SGG")
			        			SGG->GG_COD     := cCodSGG
	                			SGG->GG_COMP    := cCodComp
			        			SGG->GG_QUANT   := nQuant
			        			SGG->GG_PERDA   := 0
								SGG->GG_XXITEM  := aLenBom[Len(aLenBom)][1]
			        			SGG->GG_INI     := dDataBase
			        			SGG->GG_FIM     := dDataBase
			        			SGG->GG_FIXVAR  := "V"
			        			SGG->GG_POTENCI := 0
			        			SGG->GG_STATUS  := "1"
			 					SGG->GG_USUARIO := LogUserName() 
			 					SGG->GG_REVFIM  := "ZZZ"
	         					SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
			 					MsunLock()

								AAdd(aLogErros,{"Estrutura",cCodComp,"Componente incluído com sucesso na pré-estrutura do "+cCodSGG+".",cArq,nLinha})

							EndIf	
                        Else
						   AAdd(aLogErros,{"Estrutura",cCodComp,"Componente já existe na pré-estrutura do "+cCodSGG+".",cArq,nLinha})
						EndIf	 

					 Else
						 AAdd(aLogErros,{"Estrutura",cCodSGG,"Componente com bloqueio no cadastro do produto.",cArq,nLinha})
				     EndIf 
  
				  Else
					 AAdd(aLogErros,{"Estrutura",cCodSGG,"Componente não encontrado no cadastrado do produto.",cArq,nLinha})
				  EndIf 	 
			
			   Else

                  dbSelectArea("SB1")
			      dbSetOrder(1)
	              If dbSeek(xFilial("SB1")+cCodStok)

				     cCodSGG := Iif(Empty(TRB->GG_COMP),cCodSb1,TRB->GG_COMP)

				     If SB1->B1_MSBLQL <> "1"

	 					dbSelectArea("SGG")
			 			dbSetOrder(1)
			 			If! dbSeek(xFilial("SGG")+cCodSGG+cCodStok)

                    		Reclock("SGG",.T.)
                    		SGG->GG_FILIAL  := xFilial("SGG")
			        		SGG->GG_COD     := cCodSGG
	                		SGG->GG_COMP    := cCodStok
			        		SGG->GG_QUANT   := nQuant
			        		SGG->GG_PERDA   := 0
							SGG->GG_XXITEM  := aLenBom[nProx][1]
			        		SGG->GG_INI     := dDataBase
			        		SGG->GG_FIM     := dDataBase
			        		SGG->GG_FIXVAR  := "V"
			        		SGG->GG_POTENCI := 0
			        		SGG->GG_STATUS  := "1"
			 				SGG->GG_USUARIO := LogUserName()
			 				SGG->GG_REVFIM  := "ZZZ"
	         				SGG->GG_OBSERV  := SubStr(cObserv,1,TamSx3("GG_OBSERV")[1])
			 				MsunLock()

							AAdd(aLogErros,{"Estrutura",cCodStok,"Componente incluído com sucesso na pré-estrutura do "+cCodSGG+".",cArq,nLinha}) 

					    Else
						    AAdd(aLogErros,{"Estrutura",cCodStok,"Componente já existe na pré-estrutura do "+cCodSGG+".",cArq,nLinha}) 
						EndIf

					 Else
					     AAdd(aLogErros,{"Estrutura",cCodStok,"Componente com bloqueio no cadastro do produto.",cArq,nLinha})
					 EndIf 
  
                  Else
                      AAdd(aLogErros,{"Estrutura",cCodStok,"Componente não encontrado no cadastrado do produto.",cArq,nLinha})
                  EndIf

			  EndIf

          EndIf
    
	   Else
	       AAdd(aLogErros,{"Estrutura",cCodComp,"Componente com bloqueio no cadastro do produto.",cArq,nLinha})
	   EndIf

    Else
     	AAdd(aLogErros,{"Estrutura",cCodComp,"Componente não encontrado no cadastro do produto.",cArq,nLinha})
	EndIf
    cItemAnt := StrTran(StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".",""),",","")
    nTamAnt  := Len(StrTran(AllTrim(aDadosItem[nI][nPosItem][1]),".",""))
	cCodSup  := cCodComp
Next

If Len(aLogErros)>0 
   If MsgYesNo("Deseja gerar o log da importação?","")
   		fImprime(cArq)
   EndIf 		   
EndIf


Return(.T.)

//------------------------------------------------
Static Function XLOG(aAutoErro)  
*-------------------------------*     
LOCAL cRet := ""
LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=alltrim(substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; ")
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet

//--------------------------------

Static Function fImprime(cArq)
Private oReport
Private oSection
Private oFont
Private cTitulo := " Importação dados "+cArq

//ASORT(aLogErros,,, { |x, y| x[5] < y[5] } ) 	

oReport:=ReportDef()
oReport:PrintDialog()

Return

//-------------------

Static Function ReportDef()
Local aOrdem :={}

oFont  :=TFont():New("Courier New",,10,,.F.,,,,.F.,.F.)

oReport:=TReport():New("U6GEN002",cTitulo,""/*_cPerg*/,{|oReport| ReportPrint(oReport)},"")

//oReport:SetLandScape()

oSection:=TRSection():New(oReport,"Relatório de LOG do importador.","",aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)

Return oReport

//------------------------------------------------------------------------

Static Function ReportPrint(oReport)
Local nCont    := 1
oReport:SetTitle(cTitulo)

TRCell():New(oSection,"OCORRE"    ,,"Ocorrência"          ,"@!"     ,050   ,.F.,)
TRCell():New(oSection,"MENSAGEM"  ,,"Mensagem"            ,"@!"     ,100   ,.F.,)
TRCell():New(oSection,"LINHA"     ,,"Linha do arquivo"    ,"@!"     ,020   ,.F.,)

oSection:Cell("OCORRE"):SetHeaderAlign("LEFT")
oSection:Cell("OCORRE"):SetAlign("LEFT")
oSection:Cell("OCORRE"):SetSize(050)

oSection:Cell("MENSAGEM"):SetHeaderAlign("LEFT")
oSection:Cell("MENSAGEM"):SetAlign("LEFT")
oSection:Cell("MENSAGEM"):SetSize(100)

oSection:Cell("LINHA"):SetHeaderAlign("LEFT")
oSection:Cell("LINHA"):SetAlign("LEFT")
oSection:Cell("LINHA"):SetSize(20)

oSection:Init()

While !oReport:Cancel() .And. nCont <= Len(aLogErros)

	  If oReport:Cancel()
		 Exit
	  EndIf
    	
	  oSection:Cell("OCORRE"):SetBlock( {|| aLogErros[nCont,2] } )
	  oSection:Cell("MENSAGEM"):SetBlock(  {|| aLogErros[nCont,3] })
	  oSection:Cell("LINHA"):SetBlock(  {|| aLogErros[nCont,5] })
      	  
	  oSection:PrintLine()
	  //oReport:SkipLine()

	  oReport:IncMeter()
	  nCont ++

	  If nCont > Len(aLogErros)
	     Exit
	  EndIf
End

oSection:Finish()
oReport:EndPage()

Return

//--------------------------------

Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
cString := _NoTags(cString)
cString := StrTran(cString,'"','')
Return cString
