USE [ISAPabrikProduksi]
GO
/****** Object:  StoredProcedure [dbo].[usp_LapBahanBaku_perTipeCairan]    Script Date: 09/08/2022 08:06:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



  
              
-- =============================================                
-- Author  : Agus S               
-- Create date : 30 Juli 2016               
-- Description : Laporan Bahan Baku per Tipe Cairan                
-- =============================================                
ALTER PROCEDURE [dbo].[usp_LapBahanBaku_perTipeCairan]                          
 @startdte date ,               
 @enddate date 
AS                
BEGIN                
 SET NOCOUNT ON;                

 --Kelompok Mesin NmMesin NmMaterial qty Sat Kotoran alumunium NmMesin NmMaterial qty sat Qty sat Kucu  
declare @IDMelting uniqueidentifier='B2343017-7687-4E30-8823-1C3EE7677C75' --MELTING NAKAYAMA  
declare @IDGravityCasting uniqueidentifier='7D79529F-19C5-4F40-81A6-69521EE30363' --GRAVITY CASTING NAKAYAMA  
declare @IDDieCasting uniqueidentifier='37B0692F-99A7-47C4-9C21-95C9B2A7A9C8' --DIE CASTING NAKAYAMA  
declare @SandCoreCasting uniqueidentifier='39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC' --CASTING SAND CORE NAKAYAMA  
  
declare @inputworkcenter0 uniqueidentifier = 'B2343017-7687-4E30-8823-1C3EE7677C75'             
declare @inputworkcenter1 uniqueidentifier = '7D79529F-19C5-4F40-81A6-69521EE30363'             
declare @inputworkcenter2 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'             
declare @inputworkcenter3 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'             
declare @inputworkcenter4 uniqueidentifier = null             
            
declare @outputworkcenter0 uniqueidentifier ='7D79529F-19C5-4F40-81A6-69521EE30363'              
declare @outputworkcenter1 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'             
declare @outputworkcenter2 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'           
            
declare @bahanbakurowidpengaruhtonnase uniqueidentifier = 'D07690EE-1333-4AF6-97EB-8E0EE67165CA'   
declare @bahanbakuRowIDResin uniqueidentifier = 'F029DA90-C9C0-4F37-8FD4-F0A3606195A5'  -- meterial Resin untuk Proses Produksi Casting sand core        
declare @prosesrowidpengaruhtonnase1 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'    -- Proses Produksi DieCasting         
declare @prosesrowidpengaruhtonnase2 uniqueidentifier = '7D79529F-19C5-4F40-81A6-69521EE30363'     -- Proses Produksi GRAVITY CASTING NAKAYAMA          
declare @prosesrowidpengaruhtonnase3 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'   -- Proses Produksi Casting sand core        
     
  
declare @LineProduksiCastingSandCore uniqueidentifier = '6C731B96-86B5-4F45-8CFC-FB0637CE9A46'  

declare @tabelmaterial table(
IDMaterial uniqueidentifier,
NmMaterial varchar(MAX),
Nama varchar(100)
)
  
declare @IDMaterialLooping uniqueidentifier
declare @looping tinyint = 2
declare @loopingstring varchar(2)
declare @createtablesql nvarchar(MAX)
declare @bahanbaku nvarchar(MAX) 
declare @hasilproduksi nvarchar(MAX)
declare @bahanbaku2 nvarchar(MAX)
declare @KotAlumunium nvarchar(MAX)
declare @KlpMesin nvarchar(MAX)
declare @selectsql1 nvarchar(MAX)
declare @selectsql2 nvarchar(MAX)
declare @selectsql3 nvarchar(MAX)
declare @selectsql4 nvarchar(MAX)
declare @execsql nvarchar(MAX)
declare @IDMaterialLoopingstring varchar(50)

declare @tableBahanBaku1 table(  
KlpMesin varchar(50),   
KdMesin varchar(50),   
NmMesin varchar(MAX),  
IDMaterial uniqueidentifier ,   
KdMaterial varchar(50),   
NmMaterial varchar(MAX),   
Qty  float,   
Satuan varchar(10)  
)

declare @tabelHasilProduksi1 table(  
KlpMesin varchar(50),   
KdMesin varchar(50),   
NmMesin varchar(MAX),
Approved varchar(MAX),
Approvedby varchar(MAX),
ApprovedDate varchar(MAX),   
IDMaterial uniqueidentifier ,   
KdMaterial varchar(50),   
NmMaterial varchar(MAX),    
sumQty float,  
sumSp float,             
sumQtyKgPcs float,   
sumSPKgPcs float,         
sumKucuKgPcs float  
)  

declare @kotAluminium1 table(  
KlpMesin varchar(50),  
KotoranAlumuniumCair float  
) 

declare @tabelKlpMesin1 table(  
KlpMesin varchar(50)  
) 

-- Sandcore  
insert into @tableBahanBaku1  
select 'SandCore' KlpMesin,'' KdMesin, '' NmMesin, pbd.MaterialRowID, m.KdMaterial , m.NmMaterial , sum(pbd.Qty) sumQty , m.Satuan        
from ISAPabrik.dbo.PemakaianBarang pb     
inner Join ISAPabrik.dbo.PemakaianBarangDetail pbd on pb.RowID = pbd.HeaderRowID            
left join isapabrik.dbo.material m on m.RowID = pbd.MaterialRowID               
where pb.LineProduksiRowID = '771A3CE0-D157-44B2-98BE-641F2ED4C146'--@LineProduksiCastingSandCore              
and pb.Tanggal between @startdte and @enddate  
and m.NmMaterial like 'RESIN%'           
group by pbd.MaterialRowID, m.KdMaterial , m.NmMaterial  , m.Satuan  

--Output dari hasil Casting   SandCore        
insert into @tabelHasilProduksi1      
select 'SandCore' KlpMesin, t.KdMesin, t.NmMesin,t.Approved,t.Approvedby,t.ApprovedDate, t.IDMaterial  , t.KdMaterial , t.NmMaterial,t.sumQty, t.sumSP,     
 sumQtyKgPcs , sumSPKgPcs , 0 --Sandcore tidak ada kucu
from               
(              
 select msn.KlpMesin, msn.KdMesin, msn.NmMesin,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial , sum(hpwod.Qty) sumQty , sum(hpwod.SPOk) sumSP  , m.Satuan , 
 SUM(sumQtyKgPcs) sumQtyKgPcs, sum(sumSPKgPcs) sumSPKgPcs          
 from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO               
 left join isapabrik.dbo.material m on m.RowID = hpwod.IDMaterial     
 left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID
 left join ISAPabrik.dbo.Mesin msn on msn.RowID = pm.MesinRowID  
 inner join HasilProsesWOKDetail hpwokd on (hpwokd.IDHPWO = hpwo.RowID and hpwod.RowID = hpwokd.IDHPWOD)    
 outer apply
 (
	select 
		hpwod.Qty*ISNULL(hpwokd.QKg,0) sumQtyKgPcs,
		hpwod2.SPOk*ISNULL(hpwokd.QKg,0) sumSPKgPcs
	from HasilProsesWODetail hpwod2
		join HasilProsesWOKDetail hpwokd2 on hpwokd2.IDHPWOD = hpwod2.RowID
	where hpwod2.RowID = hpwod.RowID
 )Kg      
 where (     
  hpwo.ProsesID = @outputworkcenter2   
  and hpwo.Approved = '1'  
 --or hpwo.IDLiniProduksi = @LineProduksiCastingSandCore    
 )               
 and hpwo.TglProses between @startdte and @enddate               
 group by hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial  , m.Satuan ,msn.KlpMesin, msn.KdMesin, msn.NmMesin,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate          
) t  
----------------------------------------  
insert into @tabelKlpMesin1  
select KlpMesin from @tableBahanBaku1 
union all  
select KlpMesin from @tabelHasilProduksi1 

--Mencari Material Alumunium Melting
insert into @tabelmaterial
select distinct hpwod.IDMaterial, 
m.NmMaterial,
case when m.NmMaterial = 'ALUMUNIUM CAIR' then 'ALM CAIR' else RIGHT(m.NmMaterial , (LEN(m.NmMaterial)-charindex('R',m.NmMaterial)-1)) end as Mat
from HasilProsesWODetail hpwod
inner join HasilProsesWO hpwo on hpwo.RowID = hpwod.IDHPWO
join ISAPabrik.dbo.material m on m.RowID = hpwod.IDMaterial
where hpwo.ProsesID = @IDMelting
and hpwod.IDMaterial <> ISAPabrik.dbo.EmptyUID()

select * from @tabelmaterial

--Mulai Perulangan
 DECLARE Temp_cursor CURSOR FOR      
 SELECT  IDMaterial FROM @tabelmaterial
 OPEN Temp_cursor; 
 
 FETCH NEXT FROM Temp_cursor INTO @IDMaterialLooping ;
 WHILE @@FETCH_STATUS = 0      
 BEGIN 

		set @loopingstring = CAST(@looping as varchar(2))

		set @createtablesql = 
		'declare @tableBahanBaku' +@loopingstring+' table(' +
		'KlpMesin varchar(50),'+   
		'KdMesin varchar(50),'+   
		'NmMesin varchar(MAX),'+  
		'IDMaterial uniqueidentifier ,'+   
		'KdMaterial varchar(50),'+   
		'NmMaterial varchar(MAX),'+   
		'Qty  float,'+   
		'Satuan varchar(10)'+
		') ' +
		'declare @tabelHasilProduksi' +@loopingstring+' table(' +  
		'KlpMesin varchar(50),   
		KdMesin varchar(50),   
		NmMesin varchar(MAX),
		Approved varchar(MAX),
		Approvedby varchar(MAX),
		ApprovedDate varchar(MAX),   
		IDMaterial uniqueidentifier ,   
		KdMaterial varchar(50),   
		NmMaterial varchar(MAX),    
		sumQty float,  
		sumSp float,             
		sumQtyKgPcs float,   
		sumSPKgPcs float,         
		sumKucuKgPcs float  
		) '+
		'declare @kotAluminium' +@loopingstring+' table(  
		KlpMesin varchar(50),  
		KotoranAlumuniumCair float  
		) '+
		'declare @tabelKlpMesin' +@loopingstring+' table(  
		KlpMesin varchar(50)  
		)'

		set @bahanbaku =
		'insert into @tableBahanBaku' +@loopingstring+' '+
		'select LTRIM(RTRIM(msn.KlpMesin)), msn.KdMesin, msn.NmMesin, hpwokd.IDMaterial , m.KdMaterial , m.NmMaterial , sum(hpwokd.Qty +hpwokd.SP) sumQty , m.Satuan             
		from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO               
		left join HasilProsesWOKDetail hpwokd on hpwokd.IDHPWOD = hpwod.RowID               
		left join isapabrik.dbo.material m on m.RowID = hpwokd.IDMaterial  
		left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID
		left join ISAPabrik.dbo.Mesin msn on msn.RowID = pm.MesinRowID             
		where hpwo.ProsesID = '+CHAR(39)+CONVERT(VARCHAR(50),@IDMelting)+CHAR(39)+' ' +              
		'and hpwo.TglProses between '+CHAR(39)+convert(varchar(10),@startdte,120)+CHAR(39)+' and '+CHAR(39)+convert(varchar(10),@enddate,120)+CHAR(39)+' '+     
		'AND hpwod.IDMaterial=' +CHAR(39)+convert(varchar(50),@IDMaterialLooping)+CHAR(39)+' '+   
		'group by hpwokd.IDMaterial , m.KdMaterial , m.NmMaterial  , m.Satuan, msn.KdMesin, msn.NmMesin,msn.KlpMesin '

		set @hasilproduksi =
		'insert into @tabelHasilProduksi' +@loopingstring+' '+
		'select LTRIM(RTRIM(t.KlpMesin)), t.KdMesin, t.NmMesin,t.Approved,t.Approvedby,t.ApprovedDate, t.IDMaterial  , t.KdMaterial , t.NmMaterial,  t.sumQty, t.sumSP,             
		 sumQtyKgPcs, sumSPKgPcs, sumKucuKgPcs         
		from               
		(              
		 select mesn.KlpMesin, mesn.KdMesin, mesn.NmMesin ,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate,hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial , sum(ISNULL(hpwod.Qty,0)) sumQty , sum(ISNULL(hpwod.SPOk,0)) sumSP  , m.Satuan, sum(ISNULL(hpwokd.QKg,0)) sumQtyKgPcs, sum(ISNULL(hpwokd.SP,0)) sumSPKgPcs, sum(ISNULL(hpwokd.QKucu,0)) sumKucuKgPcs             
		 from HasilProsesWO hpwo 
		 inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO               
		 left join isapabrik.dbo.material m on m.RowID = hpwod.IDMaterial     
		 left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID
		 left join ISAPabrik.dbo.Mesin mesn on mesn.RowID = pm.MesinRowID   
		 inner join HasilProsesWOKDetail hpwokd on (hpwokd.IDHPWO = hpwo.RowID and hpwod.RowID = hpwokd.IDHPWOD)         
		 where (     
		 hpwo.ProsesID = '+Char(39)+convert(varchar(50),@outputworkcenter0)+Char(39)+' or hpwo.ProsesID = '+Char(39)+convert(varchar(50),@outputworkcenter1)+Char(39)+' '+   
		 '
		 and hpwo.Approved = 1 )               
		 and hpwo.TglProses between '+CHAR(39)+convert(varchar(10),@startdte,120)+CHAR(39)+' and '+CHAR(39)+convert(varchar(10),@enddate,120)+CHAR(39)+' '+  
		 'and hpwokd.TipeItem = 0' + 
		 'and hpwokd.IDMaterial= '+Char(39)+convert(varchar(50),@IDMaterialLooping)+Char(39) +'  '+            
		 'group by hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial  , m.Satuan , mesn.KlpMesin, mesn.KdMesin, mesn.NmMesin,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate , hpwokd.IDMaterial            
		) t'               

		set @bahanbaku2 =
		'insert into @tableBahanBaku' +@loopingstring+' '+
		'select LTRIM(RTRIM(msn.KlpMesin)),msn.KdMesin, msn.NmMesin, hpwokd.IDMaterial , m.KdMaterial , m.NmMaterial , sum(hpwokd.Qty) sumQty , m.Satuan          
		from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO               
		left join HasilProsesWOKDetail hpwokd on hpwokd.IDHPWOD = hpwod.RowID               
		left join isapabrik.dbo.material m on m.RowID = hpwokd.IDMaterial       
		left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID     
		left join ISAPabrik.dbo.Mesin msn on pm.MesinRowID=msn.RowID      
		where (hpwo.ProsesID = '+Char(39)+convert(varchar(50),@IDGravityCasting)+Char(39)+' OR hpwo.ProsesID = '+Char(39)+convert(varchar(50),@IDDieCasting)+Char(39)+' )'+            
		'and hpwo.TglProses between '+CHAR(39)+convert(varchar(10),@startdte,120)+CHAR(39)+' and '+CHAR(39)+convert(varchar(10),@enddate,120)+CHAR(39)+' '+    
		'AND m.NmMaterial like '+CHAR(39)+Convert(varchar(10),'insert%')+CHAR(39)+' '+    
		' AND msn.KlpMesin in  
		(  
		select distinct KlpMesin from @tabelHasilProduksi' +@loopingstring+' '+  
		')     
		group by hpwokd.IDMaterial , m.KdMaterial , m.NmMaterial  , m.Satuan, msn.KdMesin, msn.NmMesin,msn.KlpMesin '
		
		set @KotAlumunium =
		'insert into @kotAluminium' +@loopingstring+' '+
		'select LTRIM(RTRIM(msn.KlpMesin)), SUM(hpwod.SPOK) KotoranAlumuniumCair            
		from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO   
		left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID     
		left join ISAPabrik.dbo.Mesin msn on pm.MesinRowID=msn.RowID        
		where hpwo.TglProses between '+CHAR(39)+convert(varchar(10),@startdte,120)+CHAR(39)+' and '+CHAR(39)+convert(varchar(10),@enddate,120)+CHAR(39)+' '+              
--		'and  
--		( hpwo.ProsesID = '+Char(39)+convert(varchar(50),@outputworkcenter0)+CHAR(39)+' or hpwo.ProsesID = '+Char(39)+convert(varchar(50),@outputworkcenter1)+CHAR(39)+' or hpwo.ProsesID = '+Char(39)+convert(varchar(50),@outputworkcenter2)+CHAR(39)+') '+  
		'and (hpwod.IDMaterial = '+Char(39)+convert(varchar(50),@IDMaterialLooping)+Char(39)+') '+  
		'Group by KlpMesin  
		order by KlpMesin'
		
		set @KlpMesin =
		'insert into @tabelKlpMesin' +@loopingstring+' '+
		'select KlpMesin from @tableBahanBaku'+ @loopingstring +'  
		union all  
		select KlpMesin from @tabelHasilProduksi'+ @loopingstring +'   
		union all  
		select KlpMesin from @kotAluminium'+ @loopingstring +' '

		set @selectsql1='select distinct KlpMesin from @tabelKlpMesin'+ @loopingstring +' order by KlpMesin'
		set @selectsql2='select * from @tableBahanBaku' + @loopingstring +' order by NmMesin '
		set @selectsql3='select * from @tabelHasilProduksi' + @loopingstring +' order by NmMesin '
		set @selectsql4='select * from @kotAluminium' +@loopingstring+' '
		
		set @execsql = @createtablesql + ' ' + @bahanbaku + ' ' +@hasilproduksi+ ' '+ @bahanbaku2 +' '+@KotAlumunium+' '+@KlpMesin+' '+ @selectsql1 +' ' + @selectsql2 +' ' + @selectsql3 +' '+@selectsql4
		exec sp_executesql @execsql

		set @createtablesql=''
		set @bahanbaku =''
		set @execsql = ''
		set @loopingstring=''
		set @looping = @looping+1

FETCH NEXT FROM Temp_cursor INTO @IDMaterialLooping ;
 END      
 CLOSE Temp_cursor;      
 DEALLOCATE Temp_cursor;     
 
 --Proses Sandcore
	select distinct KlpMesin from @tabelKlpMesin1 order by KlpMesin
	select * from @tableBahanBaku1
	select * from @tabelHasilProduksi1
	select * from @kotAluminium1
END   


