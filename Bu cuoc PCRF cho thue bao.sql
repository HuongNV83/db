SELECT TRANS_ID,response,amount,a.* FROM dsp_sys_log a WHERE isdn = '908061279' AND exec_datetime >= TO_DATE ('28/12/2022', 'dd/mm/yyyy')
--AND exec_datetime < TO_DATE ('15/12/2022', 'dd/mm/yyyy') + 1
AND response LIKE '%5000000001839083%'
ORDER BY exec_datetime;

SELECT * FROM dsp_recharge WHERE isdn = '908061279' ORDER BY issue_date;
COMMIT;
/*rollback;*/
--------------------------------------------------------------------------------
INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DFD60',4194304,30,'120000008176718','0','0',NULL,'545617',NULL);
INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'C90N',4194304,30,'120000008176718','0','0',NULL,'545617',NULL);
--------------------------------------------------------------------------------
INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT42',4194304,30,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT56',5242880,30,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT84',8388608,30,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT28',2935808,10,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT14',1468416,10,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DC10',1048576,10,'120000008176718','0','0',NULL,'545617',NULL);

INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DC5',1048576,1,'120000008176718','0','0',NULL,'545617',NULL);
INSERT INTO dsp_recharge
VALUES ('908061279',SYSDATE,'DataQT150',3145728,30,'120000008176718','0','0',NULL,'545617',NULL);
