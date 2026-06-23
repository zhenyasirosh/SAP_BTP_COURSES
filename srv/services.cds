using {sap.capire.incidents as my} from '../db/schema';
using { Northwind } from './external/Northwind';

type NorthwindOrder {
    OrderID      : Integer;
    CustomerID   : String;
    EmployeeID   : Integer;
    OrderDate    : DateTime;
    ShipName     : String;
    ShipCity     : String;
    ShipCountry  : String;
  }

/**
 * Service used by support personell, i.e. the incidents' 'processors'.
 */
service ProcessorService {
    @cds.redirection.target
    entity Incidents       as projection on my.Incidents;

    @readonly
    entity Customers       as projection on my.Customers;

    @readonly
    entity Ratings         as projection on my.Ratings;

    entity Comments        as projection on my.Comments;

    entity Items           as projection on my.Items;

    @readonly
    entity ListOfIncidents as
        projection on my.Incidents {
            ID,
            title,
            customer
        };

    function getItemsByQuantity(quantity: Integer) returns array of Items;

    function getOrders(top: Integer, skip: Integer) returns array of NorthwindOrder;

    function getOrders2(top: Integer, skip: Integer) returns array of NorthwindOrder;

    action createItem(
        title: String,
        description: String,
        quantity: Integer
    ) returns Items;
}

annotate ProcessorService.Incidents with @odata.draft.enabled;
annotate ProcessorService with @(requires: 'support');

/**
 * Service used by administrators to manage customers and incidents.
 */
service AdminService {
    entity Customers as projection on my.Customers;
    entity Incidents as projection on my.Incidents;
}
annotate AdminService with @(requires: 'admin');
