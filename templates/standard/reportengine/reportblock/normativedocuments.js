/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockNormativeDocuments extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    this.format.writeHtml(this.section.text)

    const dd = this.designDataObjectDefinition('ND')
    const list = this.designData.objects.list('ND')
    if (list.length === 0) {

    } else {
      const table = new ReportFramework.ReportTable.Table(0, 4)
      table.horizontalHeader.setStyle(-1, 'tableHeader')
      table.horizontalHeader.addRow()
      table.horizontalHeader.setCaption(0, 'Number')
      // table.horizontalHeader.setWidth(0, ReportUtils.mm2pt(10))
      table.horizontalHeader.setCaption(1, 'Title')
      table.horizontalHeader.setWidth(1, ReportFramework.ReportUtils.mm2pt(60))
      table.horizontalHeader.setCaption(2, 'Publication Date')
      // table.horizontalHeader.setWidth( 2, ReportUtils.mm2pt( 60 ) )
      table.horizontalHeader.setCaption(3, 'Revision')
      table.horizontalHeader.setWidth(3, ReportFramework.ReportUtils.mm2pt(20))
      Utils.Sort.byAttributes(list, [dd.attributes.number, dd.attributes.title])
        .forEach(nd => {
          const r = table.appendRow()
          r.cell(0).setData(nd.attributes.number)
          r.cell(1).setData(nd.attributes.title)
          r.cell(2).setData(nd.attributes.publicationdate)
          r.cell(3).setData(nd.attributes.revision)
        })
      this.writeTable(table)
    }
  }

  /* reposyd-reportblock-body */
  static DefaultSettings () {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: []
    }
    /* reposyd-reportblock-settings */
  }
}
module.exports = ReportBlockNormativeDocuments
