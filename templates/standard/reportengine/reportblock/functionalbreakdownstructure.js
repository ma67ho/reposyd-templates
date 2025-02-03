/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockFunctionalBreakdown extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    /* reposyd-reportblock-constructor */
    this.translations =
      /* reposyd-reportblock-translations */
      {
        de: {
          description: 'Beschreibung',
          in: 'Eingabe',
          out: 'Ausgabe',
          'table.caption': 'Eingabe/Ausgabe',
          title: 'Titel',
          type: 'Typ'
        },
        en: {
          description: 'Description',
          in: 'Input',
          out: 'Output',
          'table.caption': 'Input/Output',
          title: 'Title',
          type: 'Type'
        }

      } /* reposyd-reportblock-translations */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    const self = this
    this.format.writeHtml(this.section.text, 'description')
    let level = -1

    const fn = this.designData.designDataObject(this.section.reportblock.options.reportblock.startingpoint)
    if (!fn) {

    } else {
      self.sectionNumber.add()
      followBreakdown(fn)
    }

    function followBreakdown (fn) {
      level++
      if (!self.section.reportblock.options.reportblock.omitchapterstoplevel || (self.section.reportblock.options.reportblock.omitchapterstoplevel && level > 0)) {
        self.addSection(self.sectionNumber.toString(), fn.attributes.title)
        self.designData.modeling.object.diagrams(fn.uuid, self.section.reportblock.options.reportblock.diagramtype).forEach(dm => {
          self.writeDiagram(dm)
        })
        self.writeHtml(fn.attributes.description, 'description')
        let interfaceItems = self.designData.designDataLinks(fn, 'hasoutputs', 'II').map(x => {
          return {
            dir: 'out',
            ddo: x.ddo
          }
        })
        interfaceItems = interfaceItems.concat(self.designData.designDataLinks(fn, 'hasinputs', 'II').map(x => {
          return {
            dir: 'in',
            ddo: x.ddo
          }
        }))
        if (interfaceItems.length > 0) {
          const table = new ReportFramework.ReportTable.Table(0, 3)
          table.horizontalHeader.setStyle(-1, 'tableHeader')
          table.horizontalHeader.addRow()
          table.horizontalHeader.setCaption(0, self.tc('title', 1))
          table.horizontalHeader.setCaption(1, self.tc('type', 1))
          table.horizontalHeader.setWidth(1, 20)
          table.horizontalHeader.setCaption(2, self.tc('description', 1))
          table.caption = `${fn.attributes.title}: ${self.tc('table.caption')}`
          interfaceItems.forEach(item => {
            const row = table.appendRow()
            row.cell(0).setData(item.ddo.attributes.title)
            row.cell(1).setData(item.dir === 'in' ? self.tc('in', 1) : self.tc('out', 1))
            row.cell(2).setData(`<html><body>${item.ddo.attributes.description}</body></html>`)
          })
          self.writeTable(table)
        }

        self.sectionNumber.add()
      }

      const dd = self.designDataObjectDefinition('FN')
      dd.attributes.number.type = 'number'
      Utils.Sort.byAttributes(self.designData.designDataLinks(fn, 'dividedinto', 'FN').map(x => x.ddo), [dd.attributes.number, dd.attributes.title])
        .forEach(item => {
          followBreakdown(item)
        })

      self.sectionNumber.remove()

      self.sectionNumber.inc()
    }
  }

  /* reposyd-reportblock-body */
  static RuleDefinition (settings) {
    /* reposyd-reportblock-rules */

    /* reposyd-reportblock-rules */
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
      reportblock: [{
        id: 'startingpoint',
        title: {
          'de-DE': 'Startpunkt',
          'en-US': 'Starting point'
        },
        type: 'select.ddo',
        ddo: {
          id: 'FN',
          selection: 'single'
        },
        options: 'FN',
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
        options: [{
          label: 'common.none',
          value: 'none'
        },
        {
          label: 'common.actd',
          value: 'actd'
        }
        ],
        selection: 'single',
        value: 'none'
      },

      {
        id: 'omitchapterstoplevel',
        title: {
          'de-DE': 'Keine Kapitel für Funktionen der obersten Ebene',
          'en-US': 'No chapters for top level functions'
        },
        type: 'boolean'
      }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}
module.exports = ReportBlockFunctionalBreakdown
