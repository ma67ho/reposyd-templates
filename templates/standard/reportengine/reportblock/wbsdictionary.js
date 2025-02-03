/* eslint-disable no-inner-declarations */
/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockWBSDictionary extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.definition = {
      tt: this.designDataObjectDefinition('TT')
    }
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    this.format.writeHtml(this.section.text)

    const wbs = this.designData.hierarchy.model('wbs', 'tree')
    if (wbs.length === 0) {

    } else {
      const sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
      sectionNumber.add()

      const self = this

      function renderDeliverables (wp) {
        const links = self.designData.links.list(wp, 'generates', 'DI')
        if (links.length === 0) {

        } else {
          const table = new ReportFramework.ReportTable.Table(0, 3)
          table.horizontalHeader.setStyle(-1, 'tableHeader')
          table.horizontalHeader.addRow()
          table.horizontalHeader.setCaption(0, 'Nummer')
          table.horizontalHeader.setWidth(0, 100)
          table.horizontalHeader.setCaption(1, 'Titel')
          table.horizontalHeader.setCaption(2, 'Typ')
          table.horizontalHeader.setWidth(2, 50)
          links
            .sort((a, b) => {
              return Utils.LexicographicalOrder.compare(a.ddo.attributes.number, b.ddo.attributes.number)
            })
            .forEach(link => {
              const row = table.appendRow()
              row.cell(0).setData(link.ddo.attributes.number)
              row.cell(1).setData(link.ddo.attributes.title)
              row.cell(2).setData(link.ddo.definition.attributes.type.properties.enumeration.find(x => x.key === link.ddo.attributes.type).value[self.document.lang])
            })
          self.writeTable(table)
        }
      }

      function renderTasks (wp) {
        self.designData.links.list(wp, 'completedby', 'TK')
          .sort((a, b) => {
            return Utils.LexicographicalOrder.compare(a.ddo.attributes.number, b.ddo.attributes.number)
          })
          .forEach(item => {
            renderTask(item.ddo)
          })
      }

      function renderTask (tk) {
        self.writeHtml(`${tk.attributes.number} ${tk.attributes.title}`, 'title')
        self.writeHtml(tk.attributes.description, 'description')
      }

      function renderWorkPackage (node) {
        self.addSection(sectionNumber.toString(), node.ddo.attributes.title, true)
        self.writeHtml(node.ddo.attributes.description, 'description')

        self.writeHtml('Vorgänge', 'title')
        renderTasks(node.ddo)
        self.writeHtml('Liefergegenstände', 'title')
        renderDeliverables(node.ddo)

        sectionNumber.add()
        node.children.sort((a, b) => {
          return Utils.LexicographicalOrder.compare(a.ddo.attributes.number, b.ddo.attributes.number)
        })
        node.children.forEach(child => {
          renderWorkPackage(child)
          sectionNumber.inc()
        })
        sectionNumber.remove()
        sectionNumber.inc()
      }
      wbs[0].children.sort((a, b) => {
        return Utils.LexicographicalOrder.compare(a.ddo.attributes.number, b.ddo.attributes.number)
      })
      wbs[0].children.forEach(node => {
        renderWorkPackage(node)
      })
    }
  }

  /* reposyd-reportblock-body */
  static RuleDefinition (settings) {
    var rule = ReportBlockWBSDictionary.DefaultSettings(settings).rule
    return rule === undefined ? null : rule
  }

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
          id: 'systemelement',
          title: {
            'de-DE': 'Systemelement',
            'en-US': 'System Element'
          },
          type: 'select',
          options: 'SE',
          selection: 'single',
          value: null
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}
module.exports = ReportBlockWBSDictionary
