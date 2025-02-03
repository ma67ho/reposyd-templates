/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockUseCases extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(section.number)
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    this.format.writeHtml(this.section.text)
    this.sectionNumber.add()

    this.designDataObjects('UC').forEach(uc => {
      this.renderUseCase(uc)
    })
  }

  renderUseCase (uc) {
    this.addDesignData('ddo', uc.uuid)

    this.addSection(this.sectionNumber.toString(), uc.attributes.title)
    this.writeHtml(uc.attributes.description, 'description')
    this.renderLinkedRequirements(uc)
  }

  renderLinkedRequirements (uc) {
    this.writeHtml(this.tc('Anforderung'), 'title')
    var requirements = this.designDataLinks(uc, 'defines', 'RT')
    if (requirements.length === 0) {
      this.writeHtml(this.tc('None'), 'description')
    } else {
      var table = new ReportFramework.ReportTable.Table(requirements.length + 1, 2)
      table.style = ReportFramework.ReportTable.Table.NoBorderStyle
      table.setData(0, 0, 'Title')
      table.setData(0, 1, 'PUID')
      var row = 1
      requirements.forEach(rt => {
        table.setData(row, 0, rt.ddo.attributes.title)
        table.setData(row, 1, rt.ddo.puid)
        table.setData(row++, 1, { target: rt.ddo.puid, type: 'destination' }, 3)
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
      reportblock: [
        {
          id: 'verification',
          title: {
            'de-DE': 'Drucke Nachweisführung',
            'en-US': 'Print Verification'
          },
          type: 'boolean',
          value: false
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockUseCases
