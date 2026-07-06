----------------------------------------------------------------------------------------------------------------------------------------------
/* CREO UNA VISTA SINGOLA PER OGNI TABELLA CON UNICAMENTE LE COLONNE CHE MI SERVONO 
   ED EVENTUALMENTE NE AGGIUNGO DI ALTRE UTILI ALLE ANALISI CHE POI ANDRO' A CARICARE SU POWER BI */
----------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA PRODOTTI ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_products 
    AS (
        SELECT 
            "product_id" id_prodotto
            , "product_name" nome_prodotto
            , "supplier_id" id_rifornitore
            , "category_id" id_categoria
            , "unit_price"::NUMERIC (6 , 2) AS prezzo_unitario
            , "units_in_stock" unità_in_magazzino
            , "units_on_order" unità_ordinate
            , "reorder_level" soglia_riordine
        FROM 
            "products"
        );

SELECT * FROM vw_products;

-----------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA CATEGORIE ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_categories
    AS (
        SELECT 
            "category_id" id_categoria
            , "category_name" nome_categoria
            , "description" descrizione
        FROM 
            "categories"
        );

SELECT * FROM vw_categories;

-----------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA RIFORNITORI ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_suppliers
    AS (
        SELECT 
            "supplier_id" id_rifornitore
            , "company_name" nome_rifornitore
            , "contact_name" chi_contattare
            , "contact_title" ruolo_da_contattare
            , "city" città
            , "country" nazione
            , "phone" telefono
        FROM 
            "suppliers"
        );

SELECT * FROM vw_suppliers;

-----------------------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA "DETTAGLI DEGLI ORDINI" ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_order_details
    AS (
        SELECT 
            "order_id" id_ordine
            , "product_id" id_prodotto
            , "quantity" quantità
            , "discount" sconto
        FROM 
            "order_details"
        );

SELECT * FROM vw_order_details;

-----------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA CORRIERI ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_shippers
    AS (
        SELECT 
            shipper_id id_corriere
            , company_name nome_corriere
        FROM 
            shippers
        );

SELECT * FROM vw_shippers;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* CREO UNA VISTA PER LA TABELLA ORDINI ASSEGNANDO NOMI ITALIANI;
   CON LA FUNZIONE CASE E ISNULL AGGIUNGO 1 COLONNA CHE MI RESTITUISCE "non spedito" SE MANCA LA DATA DI SPEDIZIONE E 'data ordine assente' SE MANCA LA DATA D'ORDINE;
   FACCIO LA STESSA IDENTICA COSA PER AGGIUNGERE 1 ALTRA COLONNA DOVE IN PIU' AGGIUNGO LA VERIFICA DEL SUPERAMENTO DELLA DATA DI SCADENZA DA PARTE DELLA SPEDIZIONE;
   IL TUTTO E' SEGUITO DA ::TEXT IN QUANTO HO IMPOSTO COME RISULTATI DELLE CONDIZIONI DEI TIPI DI DATO TESTO (QUINDI DIFFERENTE DALLE DATE), ALTRIMENTI DAVA UN ERRORE */
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE  OR REPLACE  VIEW vw_orders
    AS (
        SELECT 
            "order_id" id_ordine
            , "customer_id" id_cliente
            , "employee_id" id_dipendente
            , "order_date" data_ordine
            , "required_date" data_scadenza
            , "shipped_date" data_spedizione
            , "ship_via" id_corriere
            , CASE 
                WHEN shipped_date ISNULL THEN 'NON SPEDITO' 
                WHEN order_date ISNULL THEN 'DATA ORDINE ASSENTE'
                ELSE (shipped_date - order_date)::text
            END giorni_per_evasione
            , CASE 
                WHEN shipped_date ISNULL THEN 'NON SPEDITO' 
                WHEN required_date ISNULL THEN 'NESSUNA SCADENZA'
                WHEN shipped_date > required_date THEN 'SCADENZA SUPERATA'
                ELSE (required_date - shipped_date)::text
            END giorni_alla_scadenza
        FROM 
            "orders"
        );

SELECT * FROM vw_orders;

-----------------------------------------------------------------------
-- CREO UNA VISTA PER LA TABELLA CLIENTI ASSEGNANDO NOMI ITALIANI.
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_customers
    AS (
        SELECT 
            "customer_id" id_cliente
            , "company_name" nome_azienda
            , "contact_title" ruolo_da_contattare
            , "city" città
            , "country" nazione
        FROM 
            "customers"
        );

SELECT * FROM vw_customers;

-----------------------------------------------------------------------
/* CREO UNA VISTA PER LA TABELLA DIPENDENTI ASSEGNANDO NOMI ITALIANI;
   UNISCO NOMI E COGNOMI IN UN UNICA TABELLA CON LA FUNZIONE CONCAT_WS */
-----------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW vw_employees
    AS (
        SELECT 
            "employee_id" id_dipendente
            , CONCAT_WS (' ' , "last_name" , "first_name") dipendente
            , "title" ruolo
            , "hire_date" data_assunzione
        FROM 
            "employees"
        );

SELECT * FROM vw_employees;

------------------------------------------------------------------------------------------------------------------------------------
-- ADESSO CREO UN ULTERIORE VISTA DOVE UNISCO TUTTE QUELLE PRECEDENTI PER EFFETTUARE ULTERIORI EVENTUALI ANALISI IN SQL.
------------------------------------------------------------------------------------------------------------------------------------

CREATE /* OR REPLACE */ VIEW VW_VISTA_COMPLETA
    AS (
        SELECT
            cat.id_categoria                   
            , nome_categoria
            , descrizione
            
            , prod.id_prodotto                   
            , nome_prodotto
            , prezzo_unitario
            , unità_in_magazzino
            , unità_ordinate
            , soglia_riordine
            
            , rif.id_rifornitore                 
            , nome_rifornitore
            , chi_contattare
            , rif.ruolo_da_contattare AS riferimento_rifornitore
            , rif.città AS città_rifornitori
            , rif.nazione AS nazione_rifornitore
            , telefono
            
            , quantità
            , sconto
            
            , ord.id_ordine                      
            , data_ordine
            , data_scadenza
            , data_spedizione
            , giorni_per_evasione
            , giorni_alla_scadenza
            
            , cus.id_cliente                   
            , nome_azienda
            , cus.ruolo_da_contattare AS riferimento_cliente
            , cus.città AS città_clienti
            , cus.nazione AS nazione_cliente
            
            , shi.id_corriere                  
            , nome_corriere
            
            , emp.id_dipendente                 
            , dipendente
            , ruolo
            , data_assunzione
        FROM
            vw_categories AS cat
        LEFT JOIN                                         
            vw_products AS prod
        ON
            prod.id_categoria = cat.id_categoria
        LEFT JOIN                                           
            vw_suppliers AS rif
        ON
            prod.id_rifornitore = rif.id_rifornitore
        LEFT JOIN                                           
            vw_order_details AS det
        ON
            prod.id_prodotto = det.id_prodotto
        LEFT JOIN                                          
            vw_orders AS ord
        ON 
            det.id_ordine = ord.id_ordine 
        LEFT JOIN                                          
            vw_customers AS cus
        ON 
            ord.id_cliente = cus.id_cliente           
        LEFT JOIN                                          
            vw_shippers AS shi
        ON 
            ord.id_corriere = shi.id_corriere 
        LEFT JOIN                                          
            vw_employees AS emp
        ON 
            ord.id_dipendente = emp.id_dipendente 
        );
            
        
SELECT * FROM VW_VISTA_COMPLETA;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
/* HO ESEGUITO TUTTE LEFT JOIN PARTENDO DALLA TABELLA PIU' ALTA PER DIMENSIONE IN MODO DA MANTENERE TUTTI GLI EVENTUALI NULL CON L'EFFETTO "VALANGA"
   DALLA VERIFA, I NULL RISULTANO ESSERE STATI MANTENUTI ED ERANO PRESENTI UNICAMENTE NELLE DATE DELLA VISTA ORDERS                                  */
----------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    nome_prodotto
    , ROUND (SUM (prezzo_unitario)::NUMERIC, 2)
    , SUM (quantità)
FROM 
    vw_vista_completa
GROUP BY 
    nome_prodotto
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODIFICO LA VISTA CREATA PRIMA DEGLI ORDINI IN MODO CHE LE COLONNE CREATE DELLE SCADENZE E DELLE EVASIONI SIANO UNICAMENTE TESTUALI
-- E AGGIUNGO SEMPRE ALTRA VISTA DEGLI ORDINI ALTRE 2 COLONNE, BASATE SU QUELLE APPENA MODIFICATE, PER AVERE I GIORNI PRECISI
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE  OR REPLACE  VIEW vw_orders
    AS (
        SELECT 
            "order_id" id_ordine
            , "customer_id" id_cliente
            , "employee_id" id_dipendente
            , "order_date" data_ordine
            , "required_date" data_scadenza
            , "shipped_date" data_spedizione
            , "ship_via" id_corriere
            , CASE 
                WHEN shipped_date ISNULL THEN 'NON SPEDITO' 
                WHEN order_date ISNULL THEN 'DATA ORDINE ASSENTE'
                ELSE 'ORDINE EVASO'
            END stato_ordine
            , CASE 
                WHEN shipped_date ISNULL OR order_date ISNULL THEN 0
                ELSE (shipped_date - order_date)
            END giorni_per_evasione 
            , CASE 
                WHEN shipped_date ISNULL THEN 'NON SPEDITO' 
                WHEN required_date ISNULL THEN 'NESSUNA SCADENZA'
                WHEN shipped_date > required_date THEN 'SCADENZA SUPERATA'
                ELSE 'SCADENZA RISPETTATA'
            END stato_scadenza
            , CASE 
                WHEN shipped_date ISNULL OR required_date ISNULL THEN NULL
                WHEN shipped_date > required_date THEN (shipped_date - required_date)
                ELSE (shipped_date - required_date)
            END giorni_alla_scadenza
            
        FROM 
            "orders"
        );

SELECT * FROM vw_orders;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TERMINATO IL REPORT IN POWER BI, ALCUNI VISUAL SONO LENTI A CARICARE, COSI VOGLIO CONTROLLARE LA PRESENZA DI INDICI NELLE TABELLE DEL DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

























