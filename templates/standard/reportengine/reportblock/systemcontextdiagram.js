/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockSystemContextDiagram extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(section.number)
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    this.format.writeHtml(this.section.text)
    const diagrams = Array.isArray(this.reportBlockOptions.diagrams) ? this.reportBlockOptions.diagrams : this.reportBlockOptions.diagrams ? [this.reportBlockOptions.diagrams] : []
    diagrams.forEach(uuid => {
      const dm = this.designData.modeling.diagram.findUuid(uuid)
      if (!dm) {
        this.writeErrorMessage(`diagram ${uuid} not found`)
      } else {
        this.renderDiagram(dm)
      }
    })
  }

  renderDiagram (dm) {
    this.sectionNumber.add()
    this.addSection(this.sectionNumber.toString(), dm.ddo.attributes.title)
    this.writeDiagram(dm)
    this.writeHtml(dm.ddo.attributes.description, 'description')

    this.sectionNumber.add()
    this.addSection(this.sectionNumber.toString(), 'Stakeholder')
    this.sectionNumber.add()
    Utils.Sort.byAttributes(dm.designDataObjects('SR'), ['title'])
      .forEach(sr => {
        this.addSection(this.sectionNumber.toString(), sr.attributes.title)
        this.sectionNumber.inc()
        // this.writeHtml( sr.attributes.title, 'title' )
        this.writeHtml(sr.attributes.description, 'description')
        this.writeHtml(`[${sr.puid}]`, 'puid')
      })
    this.sectionNumber.remove()
    this.sectionNumber.inc()
    this.addSection(this.sectionNumber.toString(), 'Externe Systeme')
    this.sectionNumber.add()
    dm.designDataObjects('SE')
      .forEach(se => {
        if (se.uuid !== dm.ddo.uuid) {
          this.addSection(this.sectionNumber.toString(), se.attributes.title)
          this.sectionNumber.inc()
          this.writeHtml(se.attributes.description, 'description')
          this.writeHtml(`[${se.puid}]`, 'puid')
        }
      })
    this.sectionNumber.remove()
    this.sectionNumber.inc()
    this.addSection(this.sectionNumber.toString(), 'Schnittstellenobjekte')
    this.sectionNumber.add()
    dm.designDataObjects('II')
      .forEach(se => {
        if (se.uuid !== dm.ddo.uuid) {
          this.addSection(this.sectionNumber.toString(), se.attributes.title)
          this.sectionNumber.inc()
          this.writeHtml(se.attributes.description, 'description')
          this.writeHtml(`[${se.puid}]`, 'puid')
        }
      })
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
          id: 'diagrams',
          title: {
            'de-DE': 'Zu druckende Diagramme',
            'en-US': 'Diagrams to be printed'
          },
          type: 'select.diagram',
          diagram: {
            type: 'scd',
            selection: 'single'
          },
          value: null
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockSystemContextDiagram
