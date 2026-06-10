const cds = require('@sap/cds');
const { SELECT } = require('@sap/cds/lib/ql/cds-ql');



class ProcessorService extends cds.ApplicationService {
  /** Registering custom event handlers */
  init() {
    this.before("UPDATE", "Incidents", (req) => this.onUpdate(req));
    this.before("CREATE", "Incidents", (req) => this.changeUrgencyDueToSubject(req.data));

    this.before("READ", "Incidents", async (req) => {
      const cutomers = await SELECT.from("Customers");
      console.log(cutomers);
    });

    const { Items } = this.entities;

    this.on("getItemsByQuantity", async req => {
      const { quantity } = req.data;

      return SELECT.from(Items)
        .where({ quantity });
    });

    this.on("createItem", async req => {
      const { title, description, quantity } = req.data;

      if (quantity > 100) req.reject`Quantity must be lower than 100!`

      const items = {
        ID: cds.utils.uuid(),
        title,
        description,
        quantity
      }

      await INSERT.into(Items).entries(items);
      return items;
    });

    return super.init();
  }

  changeUrgencyDueToSubject(data) {
    let urgent = data.title?.match(/urgent/i)
    if (urgent) data.urgency_code = 'H'
  }

  /** Custom Validation */
  async onUpdate(req) {
    let closed = await SELECT.one(1).from(req.subject).where`status.code = 'C'`
    if (closed) req.reject`Can't modify a closed incident!`
  }

}


module.exports = { ProcessorService }
