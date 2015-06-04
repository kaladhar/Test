Public class searchTestController  {
public string searchText{get;set;} 
public string test {get;set;}
    public searchTestController(ApexPages.StandardController controller) {
    Case c = (Case) controller.getRecord() ;
searchText ='http://turbotax.intuit.com/support/search.jsp?pg=0&nav=&txid=1&custView=&q=Where is+my+refund?&yr=&pr=&cat=';

//test = c.Account.Name ;

 //fetch related opportunity litigation ids
    for (Case  c1 : [Select id, Description,Reason
                                         From Case
                                         Where Id = :c.Id]) {
      test = c1.Description;
      searchText = 'http://turbotax.intuit.com/support/search.jsp?pg=0&nav=&txid=1&custView=&q=' + test + '&yr=&pr=&cat=';                                                 
    }

    }
}