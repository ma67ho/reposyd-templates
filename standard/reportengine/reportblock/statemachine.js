/* reposyd-reportblock-header */
const ReportBlock = require('ReportFramework').ReportBlock
const Utils = require('Utils')
/* reposyd-reportblock-header */
class ReportBlockSystemBreakdown extends ReportBlock {
  constructor(section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */
  renderContent () {
    const self = this
    this.format.writeHtml(this.section.text)
    const dm = this.diagrams.findUuid(this.section.reportblock.options.reportblock.diagramtoprint)
    if (dm) {
      this.writeDiagram(dm)
      this.sectionNumber.add()
      Utils.Sort.byAttributes(dm.designDataObjects('ST'), ['title'])
        .forEach(st => {
          this.addSection(this.sectionNumber.toString(), st.attributes.title)
          this.writeHtml(st.attributes.description, 'description')
          this.writeHtml(`[${st.puid}]`, 'puid')
          this.sectionNumber.inc()
        })
      this.sectionNumber.remove()
    }
  }
  /* reposyd-reportblock-body */
  static RuleDefinition (settings) {
    var rule = ReportBlockRequirements.DefaultSettings(settings).rule;
    return rule === undefined ? null : rule
  }
  static DefaultSettings (settings) {
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
          id: 'startingpoint',
          title: {
            'de-DE': 'Startpunkt',
            'en-US': 'Starting point'
          },
          type: 'select',
          options: 'SE',
          selection: 'single',
          value: 'none'
        },
        {
          id: 'diagramtoprint',
          title: {
            'de-DE': 'Zu druckendes Diagramm',
            'en-US': 'Diagram to print'
          },
          type: 'select.diagram',
          diagram: {
            type: 'stmd'
          },
          selection: 'single',
          value: 'none'
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockSystemBreakdown
