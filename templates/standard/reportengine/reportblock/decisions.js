/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
/* reposyd-reportblock-header */
class ReportBlockDecisions extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    /* reposyd-reportblock-constructor */
    this.translations =
    /* reposyd-reportblock-translations */
    {
      de: {
        alternative: 'Alternative | Alternativen',
        description: 'Beschreibung',
        in: 'Eingabe',
        none: 'Keine',
        notdefined: 'nicht definiert',
        out: 'Ausgabe',
        processingstatus: 'Bearbeitungsstatus',
        rationale: 'Begründung',
        title: 'Titel',
        type: 'Typ'
      },
      en: {
        alternative: 'alternative | alternatives',
        description: 'Description',
        in: 'Input',
        none: 'none',
        notdefined: 'nicht defined',
        out: 'Output',
        processingstatus: 'processing status',
        rationale: 'rationale',
        title: 'Title',
        type: 'Type'
      }
    } /* reposyd-reportblock-translations */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    // eslint-disable-next-line no-unused-vars
    const self = this
    this.format.writeHtml(this.section.text, 'description')

    const list = this.designData.objects.filter({
      id: 'DN',
      definition: {
        and: [
          {
            id: 'state',
            conditions: [
              ['in', this.section.reportblock.options.reportblock.state]
            ],
            type: 'dda'
          }
        ]
      }
    })
    if (list.length === 0) {

    } else {
      this.sectionNumber.add()
      list.forEach(dn => {
        this.addDesignData('ddo', dn.uuid)
        this.addSection(this.sectionNumber.toString(), dn.attributes.title)
        this.writeAttribute(dn, 'description', 'description')
        this.writeText('\n')
        this.writeText(`${this.tc('processingstatus')}: ${this.designData.attribute.get(dn, 'state')}`, {
          font: {
            capitalize: true
          },
          style: {
            bold: true
          }
        })
        this.writeText('\n')
        this.writeText(this.tc('rationale'), {
          font: {
            capitalize: true
          },
          style: {
            bold: true
          }
        })
        if (!this.writeAttribute(dn, 'rationale', 'description')) {
          this.writeText(this.tc('none') + '\n', {
            style: {
              italic: true
            }
          })
        }

        this.writeText(this.tc('alternative', 2), {
          font: {
            capitalize: true
          },
          style: {
            bold: true
          }
        })
        if (dn.attributes.alternatives.alternatives.length === 0) {
          this.writeText(this.tc('notdefined') + '\n')
        } else {
          this.sectionNumber.add()
          dn.attributes.alternatives.alternatives.forEach(alt => {
            this.addSection(this.sectionNumber.toString(), alt.title)
            this.writeHtml(alt.description, 'description')

            this.sectionNumber.inc()
          })
          this.sectionNumber.remove()
        }
        this.sectionNumber.inc()
      })
    }
  }

  /* reposyd-reportblock-body */
  static RuleDefinition () {
    /* reposyd-reportblock-rules */

    /* reposyd-reportblock-rules */
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
      reportblock: [{
        id: 'state',
        label: {
          'de-DE': 'Status der Entscheidung',
          'en-US': 'Status of the decision'
        },
        title: {
          'de-DE': 'Status der Entscheidung',
          'en-US': 'Type of Requirement'
        },
        type: 'select.attribute',
        dda: {
          ddo: 'DN',
          id: 'state',
          selection: 'multiple'
        },
        value: ['pending']
      }]
    }
    /* reposyd-reportblock-settings */
  }
}
module.exports = ReportBlockDecisions
