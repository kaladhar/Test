//Generated by wsdl2apex

public class sapComDocumentSapSoapFunctionsMcS {
    public class ZpnaPurchGift {
        public String ItmNumber;
        public String Material;
        public String ShortText;
        public String Quantity;
        public String RefMaterial;
        public String AddReason;
        private String[] ItmNumber_type_info = new String[]{'ItmNumber','urn:sap-com:document:sap:rfc:functions','numeric6','1','1','false'};
        private String[] Material_type_info = new String[]{'Material','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] ShortText_type_info = new String[]{'ShortText','urn:sap-com:document:sap:rfc:functions','char40','1','1','false'};
        private String[] Quantity_type_info = new String[]{'Quantity','urn:sap-com:document:sap:rfc:functions','quantum13.3','1','1','false'};
        private String[] RefMaterial_type_info = new String[]{'RefMaterial','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] AddReason_type_info = new String[]{'AddReason','urn:sap-com:document:sap:rfc:functions','char20','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ItmNumber','Material','ShortText','Quantity','RefMaterial','AddReason'};
    }
    public class ZpnaPriceCheck_element {
        public String CustXref;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaItemsIn ItemsIn;
        public String Kunnr;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaMessages MessageOut;
        public String PoType;
        public String PriceId;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaSourceCodeOut PromoCode;
        public sapComDocumentSapSoapFunctionsMcS.ZpnaShiptoAddress ShiptoAddress;
        public String SoType;
        public String SourceCode;
        private String[] CustXref_type_info = new String[]{'CustXref','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] ItemsIn_type_info = new String[]{'ItemsIn','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaItemsIn','0','1','false'};
        private String[] Kunnr_type_info = new String[]{'Kunnr','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] MessageOut_type_info = new String[]{'MessageOut','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaMessages','0','1','false'};
        private String[] PoType_type_info = new String[]{'PoType','urn:sap-com:document:sap:rfc:functions','char4','0','1','false'};
        private String[] PriceId_type_info = new String[]{'PriceId','urn:sap-com:document:sap:rfc:functions','char10','0','1','false'};
        private String[] PromoCode_type_info = new String[]{'PromoCode','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaSourceCodeOut','0','1','false'};
        private String[] ShiptoAddress_type_info = new String[]{'ShiptoAddress','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaShiptoAddress','0','1','false'};
        private String[] SoType_type_info = new String[]{'SoType','urn:sap-com:document:sap:rfc:functions','char4','0','1','false'};
        private String[] SourceCode_type_info = new String[]{'SourceCode','urn:sap-com:document:sap:rfc:functions','char100','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CustXref','ItemsIn','Kunnr','MessageOut','PoType','PriceId','PromoCode','ShiptoAddress','SoType','SourceCode'};
    }
    public class ZpnaFeeDetails {
        public String CondType;
        public String CondValue;
        public String Currency_x;
        public String Text;
        private String[] CondType_type_info = new String[]{'CondType','urn:sap-com:document:sap:rfc:functions','char4','1','1','false'};
        private String[] CondValue_type_info = new String[]{'CondValue','urn:sap-com:document:sap:rfc:functions','curr13.2','1','1','false'};
        private String[] Currency_x_type_info = new String[]{'Currency','urn:sap-com:document:sap:rfc:functions','cuky5','1','1','false'};
        private String[] Text_type_info = new String[]{'Text','urn:sap-com:document:sap:rfc:functions','char20','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CondType','CondValue','Currency_x','Text'};
    }
    public class ZpnaPurchGiftT {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaPurchGift[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaPurchGift','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZpnaPriceCheckResponse_element {
        public String CustomerId;
        public sapComDocumentSapSoapFunctionsMcS.ZpnaFeeDetailsT Fees;
        public sapComDocumentSapSoapFunctionsMcS.ZpnaPurchGiftT Gifts;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaItemsIn ItemsIn;
        public sapComDocumentSapSoapFunctionsMcS.ZpnaItemsOutT ItemsOut;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaMessages MessageOut;
        public sapComDocumentSapSoapFunctionsMcS.TableOfZpnaSourceCodeOut PromoCode;
        private String[] CustomerId_type_info = new String[]{'CustomerId','urn:sap-com:document:sap:rfc:functions','char10','1','1','false'};
        private String[] Fees_type_info = new String[]{'Fees','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaFeeDetailsT','1','1','false'};
        private String[] Gifts_type_info = new String[]{'Gifts','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaPurchGiftT','1','1','false'};
        private String[] ItemsIn_type_info = new String[]{'ItemsIn','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaItemsIn','1','1','false'};
        private String[] ItemsOut_type_info = new String[]{'ItemsOut','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaItemsOutT','1','1','false'};
        private String[] MessageOut_type_info = new String[]{'MessageOut','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaMessages','1','1','false'};
        private String[] PromoCode_type_info = new String[]{'PromoCode','urn:sap-com:document:sap:soap:functions:mc-style','TableOfZpnaSourceCodeOut','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CustomerId','Fees','Gifts','ItemsIn','ItemsOut','MessageOut','PromoCode'};
    }
    public class TableOfZpnaSourceCodeOut {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaSourceCodeOut[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaSourceCodeOut','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class TableOfZpnaMessages {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaMessages[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaMessages','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZpnaItemsIn {
        public String ItemNbr;
        public String Matnr;
        public String Qty;
        public String Uom;
        public String ReqDate;
        public String Werks;
        private String[] ItemNbr_type_info = new String[]{'ItemNbr','urn:sap-com:document:sap:rfc:functions','numeric6','1','1','false'};
        private String[] Matnr_type_info = new String[]{'Matnr','urn:sap-com:document:sap:rfc:functions','char35','1','1','false'};
        private String[] Qty_type_info = new String[]{'Qty','urn:sap-com:document:sap:rfc:functions','quantum15.3','1','1','false'};
        private String[] Uom_type_info = new String[]{'Uom','urn:sap-com:document:sap:rfc:functions','unit3','1','1','false'};
        private String[] ReqDate_type_info = new String[]{'ReqDate','urn:sap-com:document:sap:rfc:functions','char10','1','1','false'};
        private String[] Werks_type_info = new String[]{'Werks','urn:sap-com:document:sap:rfc:functions','char4','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ItemNbr','Matnr','Qty','Uom','ReqDate','Werks'};
    }
    public class ZpnaSourceCodeOut {
        public String PromoCd;
        public String Valid;
        public String Reason;
        public String MsgNo;
        private String[] PromoCd_type_info = new String[]{'PromoCd','urn:sap-com:document:sap:rfc:functions','char24','1','1','false'};
        private String[] Valid_type_info = new String[]{'Valid','urn:sap-com:document:sap:rfc:functions','char1','1','1','false'};
        private String[] Reason_type_info = new String[]{'Reason','urn:sap-com:document:sap:rfc:functions','char220','1','1','false'};
        private String[] MsgNo_type_info = new String[]{'MsgNo','urn:sap-com:document:sap:rfc:functions','numeric3','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'PromoCd','Valid','Reason','MsgNo'};
    }
    public class ZpnaShiptoAddress {
        public String Country;
        public String Region;
        public String PostalCode;
        public String TaxCode;
        private String[] Country_type_info = new String[]{'Country','urn:sap-com:document:sap:rfc:functions','char3','1','1','false'};
        private String[] Region_type_info = new String[]{'Region','urn:sap-com:document:sap:rfc:functions','char3','1','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','urn:sap-com:document:sap:rfc:functions','char10','1','1','false'};
        private String[] TaxCode_type_info = new String[]{'TaxCode','urn:sap-com:document:sap:rfc:functions','char15','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Country','Region','PostalCode','TaxCode'};
    }
    public class TableOfZpnaItemsIn {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaItemsIn[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaItemsIn','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZpnaItemsOut {
        public String ItemNbr;
        public String Matnr;
        public String Qty;
        public String CustMatnr;
        public String NetValue1;
        public String Currency_x;
        public String Freight;
        public String Taxes;
        public sapComDocumentSapSoapFunctionsMcS.ZpnaFeeDetailsT Fees;
        private String[] ItemNbr_type_info = new String[]{'ItemNbr','urn:sap-com:document:sap:rfc:functions','numeric6','1','1','false'};
        private String[] Matnr_type_info = new String[]{'Matnr','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] Qty_type_info = new String[]{'Qty','urn:sap-com:document:sap:rfc:functions','quantum15.3','1','1','false'};
        private String[] CustMatnr_type_info = new String[]{'CustMatnr','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] NetValue1_type_info = new String[]{'NetValue1','urn:sap-com:document:sap:rfc:functions','char28','1','1','false'};
        private String[] Currency_x_type_info = new String[]{'Currency','urn:sap-com:document:sap:rfc:functions','cuky5','1','1','false'};
        private String[] Freight_type_info = new String[]{'Freight','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] Taxes_type_info = new String[]{'Taxes','urn:sap-com:document:sap:rfc:functions','char18','1','1','false'};
        private String[] Fees_type_info = new String[]{'Fees','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaFeeDetailsT','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ItemNbr','Matnr','Qty','CustMatnr','NetValue1','Currency_x','Freight','Taxes','Fees'};
    }
    public class zpna_price_check {
        public String endpoint_x = 'http://selddb.hsi.hughessupply.com:8000/sap/bc/srt/rfc/sap/zpna_price_check/110/zpna_price_check/zpna_price_check';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'sapComDocumentSapSoapFunctionsMcS', 'urn:sap-com:document:sap:rfc:functions', 'sapComDocumentSapRfcFunctions'};
        public sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheckResponse_element ZpnaPriceCheck(String CustXref,sapComDocumentSapSoapFunctionsMcS.TableOfZpnaItemsIn ItemsIn,String Kunnr,sapComDocumentSapSoapFunctionsMcS.TableOfZpnaMessages MessageOut,String PoType,String PriceId,sapComDocumentSapSoapFunctionsMcS.TableOfZpnaSourceCodeOut PromoCode,sapComDocumentSapSoapFunctionsMcS.ZpnaShiptoAddress ShiptoAddress,String SoType,String SourceCode) {
            sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheck_element request_x = new sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheck_element();
            sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheckResponse_element response_x;
            request_x.CustXref = CustXref;
            request_x.ItemsIn = ItemsIn;
            request_x.Kunnr = Kunnr;
            request_x.MessageOut = MessageOut;
            request_x.PoType = PoType;
            request_x.PriceId = PriceId;
            request_x.PromoCode = PromoCode;
            request_x.ShiptoAddress = ShiptoAddress;
            request_x.SoType = SoType;
            request_x.SourceCode = SourceCode;
            Map<String, sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheckResponse_element> response_map_x = new Map<String, sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheckResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZpnaPriceCheck',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZpnaPriceCheckResponse',
              'sapComDocumentSapSoapFunctionsMcS.ZpnaPriceCheckResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
    public class ZpnaItemsOutT {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaItemsOut[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaItemsOut','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZpnaMessages {
        public String Type_x;
        public String Id;
        public String Number_x;
        public String Message;
        private String[] Type_x_type_info = new String[]{'Type','urn:sap-com:document:sap:rfc:functions','char1','1','1','false'};
        private String[] Id_type_info = new String[]{'Id','urn:sap-com:document:sap:rfc:functions','char20','1','1','false'};
        private String[] Number_x_type_info = new String[]{'Number','urn:sap-com:document:sap:rfc:functions','numeric3','1','1','false'};
        private String[] Message_type_info = new String[]{'Message','urn:sap-com:document:sap:rfc:functions','char220','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'Type_x','Id','Number_x','Message'};
    }
    public class ZpnaFeeDetailsT {
        public sapComDocumentSapSoapFunctionsMcS.ZpnaFeeDetails[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style','ZpnaFeeDetails','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
}