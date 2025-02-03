/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockSystemBreakdown extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    const self = this
    this.format.writeHtml(this.section.text)
    if (this.section.reportblock.options.reportblock.diagramtoprint && this.section.reportblock.options.reportblock.diagramtoprint !== 'none') {
      const dm = this.designData.modeling.diagram.findUuid(this.section.reportblock.options.reportblock.diagramtoprint)
      this.writeDiagram(dm)
    }
    const se = this.designData.designDataObject(this.section.reportblock.options.reportblock.startingpoint)
    if (!se) {

    } else {
      self.sectionNumber.add()
      followBreakdown(se)
    }

    function followBreakdown (se) {
      self.addSection(self.sectionNumber.toString(), se.attributes.title)
      // self.designData.modeling.object.diagrams(se.uuid, self.section.reportblock.options.reportblock.diagramtype).forEach(dm => {
      //   self.writeDiagram(dm)
      // })
      self.writeHtml(se.attributes.description, 'description')

      self.sectionNumber.add()
      Utils.Sort.byAttributes(self.designData.designDataLinks(se, 'dividedinto', 'se').map(x => x.ddo), [se.definition.attributes.number, se.definition.attributes.title])
        .forEach(ddo => {
          followBreakdown(ddo)
          self.sectionNumber.inc()
        })

      // self.designData.designDataLinks(se, 'dividedinto', 'se').forEach(item => {
      //   followBreakdown(item.ddo)
      // })

      self.sectionNumber.remove()

      self.sectionNumber.inc()
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
          id: 'startingpoint',
          title: {
            'de-DE': 'Startpunkt',
            'en-US': 'Starting point'
          },
          type: 'select.ddo',
          ddo: {
            id: 'SE',
            selection: 'single'
          },
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
            type: 'sbsd'
          },
          selection: 'single',
          value: 'none'
        },
        {
          id: 'diagramtype',
          title: {
            'de-DE': 'Diagramart',
            'en-US': 'Diagram type'
          },
          type: 'select.value',
          options: [
            { label: 'common.none', value: 'none' },
            { label: 'common.sbsd', value: 'sbsd' }
          ],
          selection: 'single',
          value: 'none'
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockSystemBreakdown
