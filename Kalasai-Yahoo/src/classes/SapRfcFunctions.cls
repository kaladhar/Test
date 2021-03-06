//Generated by wsdl2apex

public class SapRfcFunctions {
    public class ZWS_PS_BLEND_MGN_Response_element {
        public String BLENDMGN;
        public SapRfcFunctions.BLENDED_MARGIN_ERRORS_element BLENDED_MARGIN_ERRORS;
        public SapRfcFunctions.MATERIAL_PRICES_element MATERIAL_PRICES;
        private String[] BLENDMGN_type_info = new String[]{'BLENDMGN','urn:sap-com:document:sap:rfc:functions','BLENDMGN_element','0','1','false'};
        private String[] BLENDED_MARGIN_ERRORS_type_info = new String[]{'BLENDED_MARGIN_ERRORS','urn:sap-com:document:sap:rfc:functions','BLENDED_MARGIN_ERRORS_element','1','1','false'};
        private String[] MATERIAL_PRICES_type_info = new String[]{'MATERIAL_PRICES','urn:sap-com:document:sap:rfc:functions','MATERIAL_PRICES_element','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'BLENDMGN','BLENDED_MARGIN_ERRORS','MATERIAL_PRICES'};
    }
    public class MATERIAL_PRICES_element {
        public SapRfcFunctions.ZWS_IN_MAT_PRICE[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions','ZWS_IN_MAT_PRICE','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZWS_PS_BLEND_MGN_element {
        public SapRfcFunctions.BLENDED_MARGIN_ERRORS_element BLENDED_MARGIN_ERRORS;
        public SapRfcFunctions.MATERIAL_PRICES_element MATERIAL_PRICES;
        private String[] BLENDED_MARGIN_ERRORS_type_info = new String[]{'BLENDED_MARGIN_ERRORS','urn:sap-com:document:sap:rfc:functions','BLENDED_MARGIN_ERRORS_element','1','1','false'};
        private String[] MATERIAL_PRICES_type_info = new String[]{'MATERIAL_PRICES','urn:sap-com:document:sap:rfc:functions','MATERIAL_PRICES_element','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'BLENDED_MARGIN_ERRORS','MATERIAL_PRICES'};
    }
    public class ZWS_ERROR_MSGS {
        public String TYPE_x;
        public String MSGNO;
        public String MSGAREA;
        public String MSGOBJ;
        public String MSGINTDESC;
        public String MSGDISPDESC;
        private String[] TYPE_x_type_info = new String[]{'TYPE','urn:sap-com:document:sap:rfc:functions','TYPE_element','0','1','false'};
        private String[] MSGNO_type_info = new String[]{'MSGNO','urn:sap-com:document:sap:rfc:functions','MSGNO_element','0','1','false'};
        private String[] MSGAREA_type_info = new String[]{'MSGAREA','urn:sap-com:document:sap:rfc:functions','MSGAREA_element','0','1','false'};
        private String[] MSGOBJ_type_info = new String[]{'MSGOBJ','urn:sap-com:document:sap:rfc:functions','MSGOBJ_element','0','1','false'};
        private String[] MSGINTDESC_type_info = new String[]{'MSGINTDESC','urn:sap-com:document:sap:rfc:functions','MSGINTDESC_element','0','1','false'};
        private String[] MSGDISPDESC_type_info = new String[]{'MSGDISPDESC','urn:sap-com:document:sap:rfc:functions','MSGDISPDESC_element','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'TYPE_x','MSGNO','MSGAREA','MSGOBJ','MSGINTDESC','MSGDISPDESC'};
    }
    public class ZWS_IN_MAT_PRICE {
        public String MATERIAL;
        public String PRICE;
        public String QUANTITY;
        public String PLANT;
        private String[] MATERIAL_type_info = new String[]{'MATERIAL','urn:sap-com:document:sap:rfc:functions','MATERIAL_element','0','1','false'};
        private String[] PRICE_type_info = new String[]{'PRICE','urn:sap-com:document:sap:rfc:functions','PRICE_element','0','1','false'};
        private String[] QUANTITY_type_info = new String[]{'QUANTITY','urn:sap-com:document:sap:rfc:functions','QUANTITY_element','0','1','false'};
        private String[] PLANT_type_info = new String[]{'PLANT','urn:sap-com:document:sap:rfc:functions','PLANT_element','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'MATERIAL','PRICE','QUANTITY','PLANT'};
    }
    public class BLENDED_MARGIN_ERRORS_element {
        public SapRfcFunctions.ZWS_ERROR_MSGS[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:rfc:functions','ZWS_ERROR_MSGS','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:rfc:functions','false','false'};
        private String[] field_order_type_info = new String[]{'item'};
    }
}