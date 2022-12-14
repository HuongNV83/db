/*DROP TABLE shop;
DROP TABLE company;*/
GRANT SELECT ON dsp_sub_service TO icccds_owner;
GRANT SELECT ON company TO dsp_owner;
GRANT SELECT, INSERT ON mo_queue TO dsp_owner;

CREATE TABLE shop
(
    shop_id      NUMBER(20)         NOT NULL
        CONSTRAINT shop_pk PRIMARY KEY,
    parent_id    NUMBER(20),
    shop_code    VARCHAR2(20 BYTE)  NOT NULL
        CONSTRAINT shop_uk
            UNIQUE,
    shop_level   NUMBER(2)          NOT NULL,
    name         VARCHAR2(80 BYTE)  NOT NULL,
    contact_name VARCHAR2(150 BYTE),
    mobile       VARCHAR2(100 BYTE),
    fax          VARCHAR2(100 BYTE),
    email        VARCHAR2(100 BYTE),
    status       VARCHAR2(1 BYTE)   NOT NULL,
    address      VARCHAR2(150 BYTE) NOT NULL,
    description  VARCHAR2(150 BYTE),
    web_user_id  NUMBER(10)         NOT NULL
        CONSTRAINT shop_am_user_fk1 REFERENCES am_user,
    create_by    VARCHAR(50)        NOT NULL,
    create_date  DATE DEFAULT SYSDATE,
    upd_by       VARCHAR(50),
    upt_date     DATE DEFAULT SYSDATE
);

CREATE SEQUENCE shop_seq
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NOCYCLE
    NOORDER
    CACHE 20
/

CREATE SEQUENCE company_seq MINVALUE 1000000 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1000000 CACHE 20 NOORDER NOCYCLE;

CREATE TABLE company
(
    com_id         NUMBER(20)     NOT NULL
        CONSTRAINT company_pk PRIMARY KEY,
    parent_id      NUMBER(20),
    com_name       NVARCHAR2(200) NOT NULL,
    shop_id        NUMBER(20)     NOT NULL,
    tax_code       VARCHAR2(50),
    bus_code       VARCHAR2(15),
    mobile         VARCHAR2(15),
    email          VARCHAR2(100),
    status         VARCHAR2(1)    NOT NULL,
    description    VARCHAR2(200),
    comp_level     NUMBER(2)      NOT NULL,
    rep_name       VARCHAR2(50),
    rep_mobile     VARCHAR2(15),
    rep_position   VARCHAR2(50),
    province       VARCHAR2(100),
    city           VARCHAR2(100),
    district       VARCHAR2(100),
    ward           VARCHAR2(100),
    address        VARCHAR2(400),
    web_user_id    NUMBER(10)     NOT NULL
        CONSTRAINT comp_am_user_fk1 REFERENCES am_user,
    api_user_id    NUMBER(10)     NOT NULL
        CONSTRAINT comp_am_user_fk2 REFERENCES am_user,
    public_key     CLOB,
    public_key_upt DATE,
    file_path      VARCHAR2(200),
    create_by      VARCHAR(50)    NOT NULL,
    create_date    DATE DEFAULT SYSDATE,
    upd_by         VARCHAR(50),
    upt_date       DATE DEFAULT SYSDATE
)
/

CREATE SEQUENCE company_seq
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NOCYCLE
    NOORDER
    CACHE 20
/

CREATE TABLE shop_level
(
    id         NUMBER(10)    NOT NULL
        CONSTRAINT shop_level_pk
            PRIMARY KEY,
    shop_level NUMBER(1)     NOT NULL
        CONSTRAINT shop_level_uk UNIQUE,
    name       VARCHAR2(200) NOT NULL
)/

INSERT INTO shop_level
VALUES (1, 1, 'C???p 1');
INSERT INTO shop_level
VALUES (2, 2, 'C???p 2');
INSERT INTO shop_level
VALUES (3, 3, 'C???p 3');
INSERT INTO shop_level
VALUES (4, 4, 'C???p 4');
COMMIT;


CREATE TABLE sub_service
(
    isdn           VARCHAR2(20)          NOT NULL,
    service        VARCHAR2(50)          NOT NULL,
    start_time     DATE                  NOT NULL,
    end_time       DATE                  NOT NULL,
    profile_code   VARCHAR2(30),
    initial_amount NUMBER(10),
    total_amount   NUMBER(15),
    serial         VARCHAR2(30),
    alert_end_time VARCHAR2(1) DEFAULT 0 NOT NULL,
    last_update    DATE,
    hid            NUMBER(15),
    request_id     VARCHAR2(100),
    channel        VARCHAR2(1)
)
/

COMMENT ON COLUMN sub_service.alert_end_time IS '1: da canh bao, 0: chua canh bao'
/
COMMENT ON COLUMN sub_service.channel IS '1: SMS, 2: WEB, 3: API'
/

CREATE INDEX sub_service_pk
    ON sub_service (isdn, service)
/
CREATE INDEX "SUB_SERVICE_HID_index"
    ON sub_service (hid)
/
CREATE INDEX "SUB_SERVICE_END_TIME_index"
    ON sub_service (end_time)
/


CREATE TRIGGER sub_service_bu
    BEFORE UPDATE
    ON sub_service
    FOR EACH ROW
BEGIN
    IF :new.end_time != :old.end_time AND :old.alert_end_time = '1' THEN
        :new.alert_end_time := '0';
    END IF;
END;
/

CREATE TABLE sub_service_history
(
    hid            NUMBER(15)            NOT NULL,
    isdn           VARCHAR2(20)          NOT NULL,
    service        VARCHAR2(50)          NOT NULL,
    start_time     DATE                  NOT NULL,
    end_time       DATE                  NOT NULL,
    cancel_time    DATE,
    profile_code   VARCHAR2(30),
    initial_amount NUMBER(10),
    total_amount   NUMBER(15),
    serial         VARCHAR2(30),
    alert_end_time VARCHAR2(1) DEFAULT 0 NOT NULL,
    last_update    DATE,
    request_id     VARCHAR2(100),
    channel        VARCHAR2(1)
)
/


CREATE OR REPLACE FUNCTION check_sub_service(p_isdn IN VARCHAR2,
                                             p_service IN VARCHAR2)
    RETURN NUMBER
    IS
    v_count NUMBER(10) := 0;
BEGIN
    SELECT COUNT(1)
    INTO v_count
    FROM dsp_owner.dsp_sub_service
    WHERE isdn = p_isdn
      AND service = p_service
      AND end_time > SYSDATE;

    IF v_count > 0
    THEN
        RETURN v_count;
    END IF;

    SELECT COUNT(1)
    INTO v_count
    FROM sub_service
    WHERE isdn = p_isdn
      AND service = p_service
      AND end_time > SYSDATE;

    RETURN v_count;
END;
/

GRANT SELECT ON dsp_sms_command TO icccds_owner;

CREATE VIEW sms_command AS
SELECT cmd_id,
       cmd_code,
       cmd_type,
       cmd_msg_content,
       cmd_param_count,
       description,
       cmd_regex,
       status
FROM dsp_sms_command
WHERE sys_type IN (1, 3);


INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_OK', 'O',
        'Qu?? kh??ch ???????c c???ng th??m {0}MB data t???c ????? cao t??? datacode (s??? d???ng t???i Vi???t Nam), th???i h???n s??? d???ng ?????n {1}.T???t t???t c??? ???ng d???ng internet ho???c kh???i ?????ng l???i m??y ????? ???????c t??nh c?????c theo g??i ???? n???p. Chi ti???t li??n h??? 9090.',
        0,
        'KH nh???n tin ????ng c?? ph??p, hi???n kh??ng s??? d???ng g??i datacode th?????ng kh??c, ????ng m?? datacode    Qu?? kh??ch ???????c c???ng th??m xMB data t???c ????? cao t??? datacode (s??? d???ng t???i Vi???t Nam), th???i h???n s??? d???ng ?????n dd/mm/yyyy. Chi ti???t li??n h??? 9090.    ',
        NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_ON_OK', 'O',
        'Qu?? kh??ch ???????c c???ng th??m {0}MB data t???c ????? cao t??? datacode addon (s??? d???ng t???i Vi???t Nam). T???ng dung l?????ng c??n l???i t??? datacode addon l?? {2}MB, th???i h???n s??? d???ng ?????n {1}.T???t t???t c??? ???ng d???ng internet ho???c kh???i ?????ng l???i m??y ????? ???????c t??nh c?????c theo g??i ???? n???p. Chi ti???t li??n h??? 9090.',
        0, 'KH nh???n tin ????ng c?? ph??p, ????ng m?? datacode addon', NULL, '1', '1');


INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA', 'I', NULL, 3,
        'KHCN N???p DATA t??? DATA-CODE th??ng th?????ng. C?? ph??p DK_DATA_Ma_data_code(N....)', 'DK DATA N\d{14}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_ON', 'I', NULL, 3,
        'KHCN N???p DATA t??? DATA-CODE AddOn. C?? ph??p DK_DATAON_Ma_data_code (A....)', 'DK DATAON A\d{14}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1', 'I', NULL, 3, '????ng k?? d???ch v??? KHCN', 'DK CB (90N|D60)\d{12}', '1',
        '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2', 'I', NULL, 5, '????ng k?? d???ch v??? KHCN (?????i l?? DK)',
        'DK CB \d{15} (90N|D60)\d{12} \d{9}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_F1', 'O',
        'Qu?? kh??ch hi???n ??ang c?? m???t m?? datacode kh??c c??n hi???u l???c. ????? n???p datacode m???i, qu?? kh??ch vui l??ng h???y g??i datacode b???ng c??ch so???n HUY_DC g???i 9xxx, trong ???? ???_??? l?? d???u c??ch. Ho???c ch??? m?? datacode c?? h???t h???n s??? d???ng. Chi ti???t li??n h??? 9090.    ',
        0, 'KH nh???n tin ????ng c?? ph??p, nh??ng ??ang s??? d???ng g??i datacode th?????ng kh??c    ', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_F2', 'O',
        'M?? datacode kh??ng h???p l???. Qu?? kh??ch vui l??ng ki???m tra l???i m?? datacode. Chi ti???t li??n h??? 9090.', 0,
        'KH nh???n tin ????ng c?? ph??p, hi???n kh??ng s??? d???ng g??i datacode th?????ng kh??c, sai m?? datacode', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_OK', 'O',
        'G??i DC90N ???? ???????c ????ng k?? th??nh c??ng cho thu?? bao {0}. Chi ti???t li??n h??? 9090. Xin c???m ??n!', 0, 'Th??nh c??ng',
        NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1_F2', 'O',
        'Qu?? kh??ch kh??ng thu???c ?????i t?????ng tham gia ch????ng tr??nh. Chi ti???t li??n h??? 9090. Xin c???m ??n!', 0,
        'Qu?? kh??ch kh??ng thu???c ?????i t?????ng tham gia ch????ng tr??nh. Chi ti???t li??n h??? 9090. Xin c???m ??n!', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F1', 'O',
        'Th??ng tin datacode kh??ng h???p l???. Qu?? kh??ch vui l??ng ki???m tra l???i. Chi ti???t li??n h??? 9090. Xin c???m ??n!', 0,
        'Th??ng tin datacode kh??ng h???p l???. Qu?? kh??ch vui l??ng ki???m tra l???i. Chi ti???t li??n h??? 9090. Xin c???m ??n!', NULL,
        '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F2', 'O',
        'Thu?? bao ????ng k?? kh??ng thu???c ?????i t?????ng tham gia ch????ng tr??nh. Chi ti???t li??n h??? 9090. Xin c???m ??n!', 0,
        'Thu?? bao ????ng k?? kh??ng thu???c ?????i t?????ng tham gia ch????ng tr??nh. Chi ti???t li??n h??? 9090. Xin c???m ??n!', NULL, '1',
        '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F3', 'O', 'Thu?? bao b??n h??ng {0} kh??ng ph???i l?? thu?? bao VAS!', 0,
        'Thu?? bao b??n h??ng {0} kh??ng ph???i l?? thu?? bao VAS!', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1_OK', 'O',
        'G??i DC90N ???? ???????c ????ng k?? th??nh c??ng. Qu?? kh??ch ???????c mi???n ph?? tho???i n???i m???ng cho t???t c??? c??c cu???c g???i d?????i 20 ph??t, 50 ph??t g???i li??n m???ng trong n?????c, 4GB data t???c ????? cao/ng??y. HSD g??i: {0}. T??? chu k??? th??? 2 tr??? ??i, gi?? g??i 90.000 ??/30 ng??y. Chi ti???t li??n h??? 9090. Xin c???m ??n!',
        0, 'Th??nh c??ng', NULL, '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'KT_DATA', 'I', NULL, 2,
        'KHCN kiem tra DATA t??? DATA-CODE th??ng th?????ng. C?? ph??p DK_DATA', 'KT DATA', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'KT_DATA_ON', 'I', NULL, 2,
        'KHCN kiem tra DATA ADDON t??? DATA-CODE ADDON. C?? ph??p DK_DATAON', 'KT DATAON', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'HUY_DATA', 'I', NULL, 2,
        'KHCN huy DATA t??? DATA-CODE th??ng th?????ng. C?? ph??p HUY_DATA', 'HUY DATA', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'HUY_DATA', 'I', NULL, 2,
        'KHCN huy DATA t??? DATA-CODE ADDON. C?? ph??p HUY_DATAON', 'HUY DATAON', '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'KT_DATA_OK', 'O',
        'Qu?? kh??ch c??n l???i {0}MB data t???c ????? cao t??? datacode (s??? d???ng t???i Vi???t Nam), th???i h???n s??? d???ng ?????n {1}. Chi ti???t li??n h??? 9090.    ',
        0, 'KH nh???n tin ????ng c?? ph??p tra c???u KT_DATA', NULL, '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'KT_DATA_ON_OK', 'O',
        'Qu?? kh??ch c??n l???i {0}MB data t???c ????? cao t??? datacode addon (s??? d???ng t???i Vi???t Nam), th???i h???n s??? d???ng ?????n {1}. Chi ti???t li??n h??? 9090.',
        0, 'KH nh???n tin ????ng c?? ph??p tra c???u KT_DATAON', NULL, '1', '1');


INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'HUY_DATA_OK', 'O',
        'Qu?? kh??ch ???? h???y th??nh c??ng g??i datacode. Chi ti???t li??n h??? 9090.', 0,
        'KH nh???n tin ????ng c?? ph??p h???y HUY_DATA', NULL, '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'HUY_DATA_ON_OK', 'O',
        'Qu?? kh??ch ???? h???y th??nh c??ng g??i datacode addon. Chi ti???t li??n h??? 9090.', 0,
        'KH nh???n tin ????ng c?? ph??p tra c???u HUY_DATAON', NULL, '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'TOP_UP_OK', 'O',
        'Qu?? kh??ch ???? n???p th??nh c??ng g??i {0}. Chi ti???t li??n h??? 9090.', 0,
        'KH nh???n tin ????ng c?? ph??p tra c???u HUY_DATAON', NULL, '1', '1');


UPDATE dsp_sms_command
SET sys_type ='3'
WHERE cmd_code IN
      ('DK_FAIL_ADD_DATA', 'DK_FAIL', 'DK_FAIL_NO_RETRY', 'NO_GPRS', 'SUB_NOT_EXIST', 'LOCK_ISDN', 'VOUCHER_USED',
       'VOUCHER_NOT_FOUND', 'INVALID_FORMAT', 'SYSTEM_ERROR', 'KT_INVALID_SRV');

COMMIT;

CREATE TABLE mt_queue
(
    id           NUMBER(15)            NOT NULL
        CONSTRAINT mt_queue_pk
            PRIMARY KEY,
    request_id   NUMBER(15),
    trans_id     VARCHAR2(1000),
    isdn         VARCHAR2(15)          NOT NULL,
    content      VARCHAR2(1000)        NOT NULL,
    shortcode    VARCHAR2(15),
    retries      NUMBER(2)   DEFAULT 3 NOT NULL,
    sent_time    TIMESTAMP(7),
    process_time TIMESTAMP(7),
    status       VARCHAR2(1) DEFAULT 0 NOT NULL
)
/

CREATE TABLE mt_history
(
    id           NUMBER(15)     NOT NULL,
    request_id   NUMBER(15),
    trans_id     VARCHAR2(1000),
    isdn         VARCHAR2(15)   NOT NULL,
    content      VARCHAR2(1000) NOT NULL,
    shortcode    VARCHAR2(15),
    retries      NUMBER(2)      NOT NULL,
    sent_time    TIMESTAMP(7),
    process_time TIMESTAMP(7)
)
/

COMMENT ON COLUMN mt_history.isdn IS 'So thue bao, dinh dang 84xxxxxxxxx'
/

COMMENT ON COLUMN mt_history.content IS 'Noi dung tin nhan SMS'
/

COMMENT ON COLUMN mt_history.shortcode IS 'Dau so dich vu'
/

COMMENT ON COLUMN mt_history.retries IS 'So lan retry con lai'
/

CREATE TABLE mo_queue
(
    request_id    NUMBER(15)                   NOT NULL
        CONSTRAINT cb_mo_queue_pk
            PRIMARY KEY,
    isdn          VARCHAR2(15)                 NOT NULL,
    content       VARCHAR2(300)                NOT NULL,
    received_time TIMESTAMP(6) DEFAULT SYSDATE NOT NULL,
    shortcode     VARCHAR2(15)                 NOT NULL,
    retries       NUMBER(2)                    NOT NULL
)
/

CREATE TABLE mo_history
(
    request_id    NUMBER(15)                   NOT NULL,
    trans_id      VARCHAR2(1000),
    isdn          VARCHAR2(15)                 NOT NULL,
    content       VARCHAR2(300)                NOT NULL,
    received_time TIMESTAMP(6) DEFAULT SYSDATE NOT NULL,
    shortcode     VARCHAR2(15)                 NOT NULL,
    retries       NUMBER(2)                    NOT NULL,
    description   VARCHAR2(100)
)
/

INSERT INTO ap_param
VALUES ('DATA', 'SRV_NAME', 'BDATASPONSOR1', 'Ten dich vu DATA');
INSERT INTO ap_param
VALUES ('DATA_ADDON', 'SRV_NAME', 'BDATASPONSOR2', 'Ten dich vu DATA_ADDON');
COMMIT;



CREATE TABLE lock_object
(
    locked_object VARCHAR2(50) NOT NULL,
    issue_date    DATE         NOT NULL,
    count         NUMBER(1)    NOT NULL,
    type          VARCHAR2(1)  NOT NULL,
    CONSTRAINT lock_object_uk
        UNIQUE (locked_object, issue_date)
)
/

COMMENT ON COLUMN lock_object.locked_object IS 'Khoa so thue bao (ISDN) hoac API user'
/

COMMENT ON COLUMN lock_object.type IS '0: isdn; 1: api_user'
/


CREATE VIEW dsp_owner.v_company AS
SELECT com_id,
       com_name,
       tax_code,
       bus_code,
       address,
       vas_mobile,
       representative,
       rep_phone,
       rep_mobile,
       rep_position,
       email,
       public_key,
       updated_key,
       user_id,
       parent_id,
       status,
       description,
       type,
       province,
       city,
       district,
       ward,
       file_path,
       cps_mobile,
       serial_prefix,
       api_public_key,
       api_updated_key,
       api_user_id,
       group_id,
       api_group_id,
       bhtt_code,
       check_date,
       bk_check_date,
       cust_type
FROM dsp_company
UNION ALL
SELECT com_id,
       com_name,
       tax_code,
       bus_code,
       address,
       cps_mobile     vas_mobile,
       rep_name       representative,
       NULL           rep_phone,
       rep_mobile,
       rep_position,
       email,
       public_key,
       public_key_upt updated_key,
       web_user_id    user_id,
       parent_id,
       status,
       description,
       NULL           type,
       province,
       city,
       district,
       ward,
       file_path,
       cps_mobile,
       NULL           serial_prefix,
       NULL           api_public_key,
       NULL           api_updated_key,
       api_user_id,
       NULL           group_id,
       NULL           api_group_id,
       NULL           bhtt_code,
       NULL           check_date,
       NULL           bk_check_date,
       '3'            cust_type
FROM icccds_owner.company;

CREATE OR REPLACE PROCEDURE dsp_owner.forward_icccds_mo(p_request_id NUMBER, p_isdn VARCHAR2, p_content VARCHAR2,
                                              p_shortcode VARCHAR2, p_retries NUMBER)
    IS
BEGIN
    INSERT INTO icccds_owner.mo_queue VALUES (p_request_id, p_isdn, p_content, SYSDATE, p_shortcode, p_retries);
    COMMIT;
END;
/